#include "KernelAdd.cuh"

__global__ void KernelAdd(int numElements, float* x, float* y, float* result) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    for (int i = idx; i < numElements; i += stride) {
        result[i] = x[i] + y[i];
    }
}