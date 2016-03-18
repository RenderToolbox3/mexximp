function pbrtElement = mexximpMaterialToMPbrt(scene, material, varargin)
%% Convert a mexximp material to an mPbrt MakeNamedMaterial element.
%
% pbrtElement = mexximpMaterialToPbrt(scene, material) cherry picks
% material properties from the given mexximp material and scene and uses
% these to create an mPbrt scene Material element.
%
% The given material should be an element with type "materials" as
% returned from mexximpSceneElements().
%
% The Assimp/mexximp material model is flexible, complicated, and messy.
% This function cherry picks from the given mexximp scene and material
% and ignores most material properties.  Only the following mexximp
% material properties are used (see mexximpConstants('materialPropertyKey'))':
%   - 'name'
%   - 'diffuse'
%   - 'specular'
%   - 'texture'
%
% By default, the new pbrt material will have type "uber", diffuse
% parameter "Kd" and specular parameter "Kr".  These may be overidden by
% passing values for these named parameters.  For example:
%   mexximpMaterialToMPbrt( ...
%       'materialType', 'anisoward', ...
%       'materialDiffuse', 'Kd', ...
%       'materialSpecular', 'Ks');
%
% Returns an MPbrtElement with identifier MakeNamedMaterial and parameters
% filled in based on mexximp material properties.
%
% pbrtElement = mexximpMaterialToMPbrt(scene, material, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('scene', @isstruct);
parser.addRequired('material', @isstruct);
parser.addParameter('materialType', 'uber', @ischar);
parser.addParameter('materialDiffuse', 'Kd', @ischar);
parser.addParameter('materialSpecular', 'Kr', @ischar);
parser.parse(scene, material, varargin{:});
scene = parser.Results.scene;
material = parser.Results.material;
materialType = parser.Results.materialType;
materialDiffuse = parser.Results.materialDiffuse;
materialSpecular = parser.Results.materialSpecular;

%% Dig out the material name.
materialName = material.name;
materialIndex = material.path{end};
pbrtName = mexximpCleanName(materialName, materialIndex);

%% Dig out diffuse and specular rgb and texture values.
properties = mPathGet(scene, cat(2, material.path, {'properties'}));
diffuseRgb = queryProperties(properties, 'key', 'diffuse', 'data', [0 0 0]);
specularRgb = queryProperties(properties, 'key', 'specular', 'data', [0 0 0]);
diffuseTexture = queryProperties(properties, 'textureSemantic', 'diffuse', 'data', '');
specularTexture = queryProperties(properties, 'textureSemantic', 'specular', 'data', '');

%% Build the pbrt material.
pbrtElement = MPbrtElement.makeNamedMaterial(pbrtName, materialType);

if ~isempty(materialDiffuse)
    if isempty(diffuseTexture)
        pbrtElement.setParameter(materialDiffuse, 'rgb', diffuseRgb(1:3));
    else
        pbrtElement.setParameter(materialDiffuse, 'texture', diffuseTexture);
    end
end

if ~isempty(materialSpecular)
    if isempty(specularTexture)
        pbrtElement.setParameter(materialSpecular, 'rgb', specularRgb(1:3));
    else
        pbrtElement.setParameter(materialSpecular, 'texture', specularTexture);
    end
end

%% Query a material property, return default if no good match.
function result = queryProperties(properties, queryField, queryValue, resultField, defaultResult)
query = {queryField, mexximpStringMatcher(queryValue)};
[resultIndex, resultScore] = mPathQuery(properties, query);
if 1 == resultScore
    result = properties(resultIndex).(resultField);
else
    result = defaultResult;
end
