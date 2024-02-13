#include <MatrixVectorMul.cuh>
#include <iostream>
#include <CommonKernels.cuh>

int main(int argc, char** argv) {
    int blockSize = atoi(argv[1]);
    int matXSize = atoi(argv[2]);
    int matYSize = atoi(argv[3]);
    
    size_t N = matXSize * matYSize;

    float *mat = (float*)malloc(N * sizeof(float));
    float *vec = (float*)malloc(matXSize * sizeof(float));
    float *res = (float*)malloc(matYSize * sizeof(float));

    FillData(mat, N);
    FillData(vec, matXSize);

    size_t pitch = 0;
    float *d_mat, *d_vec, *d_res;

    cudaMallocPitch(&d_mat, &pitch, matXSize * sizeof(float), matYSize);
    cudaMallocPitch(&d_vec, &pitch, matXSize * sizeof(float), 1);
    cudaMalloc(&d_res, matYSize * sizeof(float));

    cudaMemcpy2D(d_mat, pitch, mat, matXSize * sizeof(float), matXSize * sizeof(float), matYSize,
                 cudaMemcpyHostToDevice);
    cudaMemcpy2D(d_vec, pitch, vec, matXSize * sizeof(float), matXSize * sizeof(float), 1,
                 cudaMemcpyHostToDevice);

    cudaEvent_t start;
    cudaEvent_t stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int numBlocks = std::min(maxBlocks, (matYSize + blockSize - 1) / blockSize);
    cudaEventRecord(start);

    MatrixVectorMul<<<numBlocks, blockSize>>>(matYSize, matXSize, d_mat, d_vec, d_res);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaMemcpy(res, d_res, matYSize * sizeof(float), cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    WriteToFile("data/04-matrix-vector-mul.txt", matXSize * matYSize, blockSize, milliseconds);

    cudaFree(d_mat);
    cudaFree(d_vec);
    cudaFree(d_res);

    free(mat);
    free(vec);
    free(res);
    return 0;
}