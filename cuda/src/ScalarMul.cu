#include <ScalarMul.cuh>

/*
 * Calculates scalar multiplication for block
 */
__global__ void ScalarMulBlock(int numElements, float* vector1, float* vector2, float* result) {
    extern __shared__ float sh_data[];
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    int local_tid = threadIdx.x;

    if (tid < numElements) {
        sh_data[local_tid] = vector1[tid] * vector2[tid];
    }
    __syncthreads();

    for (int step = blockDim.x / 2; step >= 1; step >>= 1) {
        if (threadIdx.x < step) {
            sh_data[local_tid] += sh_data[local_tid + step];
            __syncthreads();
        } else {
            break;
        }
    }

    if (threadIdx.x == 0) {
        result[blockIdx.x] = sh_data[0];
    }
}