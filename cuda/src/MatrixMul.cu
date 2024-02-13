#include <MatrixMul.cuh>

__global__
void MatrixMul(int heightA, int widthA, int widthB, float *matrixA, float *matrixB, float *matrixResult) {
extern __shared__ float sh_data[];
    float* A_window = sh_data;
    float* B_window = (float*)&A_window[blockDim.x * blockDim.y];

    size_t row = blockIdx.y * blockDim.y + threadIdx.y;
    size_t col = blockIdx.x * blockDim.x + threadIdx.x;

    int widthA_blocks = (widthA + blockDim.x - 1) / blockDim.x;
    float thread_sum = 0.0;

    for (int aBlockIdx = 0; aBlockIdx < widthA_blocks; ++aBlockIdx) {
        size_t curr_ind_a = aBlockIdx * blockDim.x + threadIdx.x;
        size_t a_idx = row * widthA + curr_ind_a;
        int a_window_ind = threadIdx.y * blockDim.x + threadIdx.x;

        if (row < heightA && curr_ind_a < widthA) {
            A_window[a_window_ind] = matrixA[a_idx];
        } else {
            A_window[a_window_ind] = 0.0f;
        }

        size_t curr_ind_b = aBlockIdx * blockDim.x + threadIdx.y;
        size_t b_idx = curr_ind_b * widthB + col;
        int b_window_ind = threadIdx.y * blockDim.x + threadIdx.x;

        if (curr_ind_b < widthA && col < widthB) {
            B_window[b_window_ind] = matrixB[b_idx];
        } else {
            B_window[b_window_ind] = 0.0f;
        }

        __syncthreads();

        for (int k = 0; k < blockDim.y; ++k) {
            thread_sum += A_window[threadIdx.y * blockDim.x + k] *
                          B_window[k * blockDim.x + threadIdx.x];
        }
        
        __syncthreads();
    }

    size_t res_ind = row * widthB + col;
    if (row < heightA && col < widthB) {
        matrixResult[res_ind] = thread_sum;
    }
}