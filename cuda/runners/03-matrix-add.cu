#include <KernelMatrixAdd.cuh>
#include <iostream>
#include <CommonKernels.cuh>

int main(int argc, char** argv) {
    int blockSize1D = atoi(argv[1]);
    int matXSize = atoi(argv[2]);
    int matYSize = atoi(argv[3]);

    size_t N = matXSize * matYSize;
    size_t size = N * sizeof(float);
    
    float *x = (float*)malloc(size);
    float *y = (float*)malloc(size);
    float *res = (float*)malloc(size);

    for (int i = 0; i < N; ++i) {
        x[i] = 1.0f;
        y[i] = 2.0f;
    }

    size_t pitch = 0;
    float *d_x, *d_y, *d_res;

    cudaMallocPitch(&d_x, &pitch, matXSize * sizeof(float), matYSize);
    cudaMallocPitch(&d_y, &pitch, matXSize * sizeof(float), matYSize);
    cudaMallocPitch(&d_res, &pitch, matXSize * sizeof(float), matYSize);

    cudaMemcpy2D(d_x, pitch, x, matXSize * sizeof(float), matXSize * sizeof(float), matYSize,
                                                                            cudaMemcpyHostToDevice);
    cudaMemcpy2D(d_y, pitch, y, matXSize * sizeof(float), matXSize * sizeof(float), matYSize,
                                                                            cudaMemcpyHostToDevice);

    cudaEvent_t start;
    cudaEvent_t stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    int numXBlocks = std::min(maxBlocks, (matXSize + blockSize1D - 1) / blockSize1D);
    int numYBlocks = std::min(maxBlocks, (matYSize + blockSize1D - 1) / blockSize1D);

    dim3 numBlocks(numXBlocks, numYBlocks);
    dim3 blockSize(blockSize1D, blockSize1D);

    KernelMatrixAdd<<<numBlocks, blockSize>>>(matYSize, matXSize, pitch / sizeof(float), d_x, d_y, d_res);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaMemcpy2D(res, matXSize * sizeof(float), d_res, pitch, matXSize * sizeof(float), matYSize,
                    cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    WriteToFile("data/03-matrix-add.txt", matXSize * matYSize, blockSize1D, milliseconds);

    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_res);

    free(x);
    free(y);
    free(res);
    return 0;
}