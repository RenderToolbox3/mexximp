// do some data conversion round trips

#include <mex.h>

#include "mexximp_util.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (2 != nrhs || !mxIsChar(prhs[0])) {
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    char* whichTest = mxArrayToString(prhs[0]);
    if (!whichTest) {
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    if (0 == strcmp("vec3", whichTest)) {
        aiVector3D* assimp_vec3;
        unsigned num_vectors = mexximp::to_assimp_vec3(prhs[1], &assimp_vec3);
        mexximp::to_matlab_vec3(assimp_vec3, &plhs[0], num_vectors);
    } else if(0 == strcmp("string", whichTest)) {
        aiString* assimp_string;
        mexximp::to_assimp_string(prhs[1], &assimp_string);
        mexximp::to_matlab_string(assimp_string, &plhs[0]);
    } else if(0 == strcmp("rgb", whichTest)) {
        aiColor3D* assimp_rgb;
        unsigned num_vectors = mexximp::to_assimp_rgb(prhs[1], &assimp_rgb);
        mexximp::to_matlab_rgb(assimp_rgb, &plhs[0], num_vectors);
    } else if(0 == strcmp("rgba", whichTest)) {
        aiColor4D* assimp_rgba;
        unsigned num_vectors = mexximp::to_assimp_rgba(prhs[1], &assimp_rgba);
        mexximp::to_matlab_rgba(assimp_rgba, &plhs[0], num_vectors);
    }
    
}
