#include "KernelAdd.cuh"
#include <iostream>
#include <CommonKernels.cuh>

int main(int argc, char** argv) {
    int blockSize = atoi(argv[1]);
    int N = atoi(argv[2]);
    int numBlocks = std::min(maxBlocks, (N + blockSize - 1) / blockSize);

    size_t size = N * sizeof(float);
    float *x = (float*)calloc(N, sizeof(float));
    float *y = (float*)calloc(N, sizeof(float));
    float *res = (float*)calloc(N, sizeof(float));

    float *d_x, *d_y, *d_res;

    cudaMalloc(&d_x, size);
    cudaMalloc(&d_y, size);
    cudaMalloc(&d_res, size);

    for (int i = 0; i < N; ++i) {
        x[i] = i;
        y[i] = -i;
    }

    cudaMemcpy(d_x, x, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, y, size, cudaMemcpyHostToDevice);

    cudaEvent_t start;
    cudaEvent_t stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    KernelAdd<<<numBlocks, blockSize>>>(N, d_x, d_y, d_res);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaMemcpy(res, d_res, size, cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    WriteToFile("data/01-add.txt", N, blockSize, milliseconds);

    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_res);

    free(x);
    free(y);
    free(res);
    return 0;
}