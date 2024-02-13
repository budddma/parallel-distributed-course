#include <ScalarMulRunner.cuh>
#include <iostream>
#include <CommonKernels.cuh>

int main(int argc, char** argv) {
    int blockSize = atoi(argv[1]);
    int N = atoi(argv[2]);

    size_t size = N * sizeof(float);

    float *x = (float*)malloc(size);

    for (int i = 0; i < N; ++i) {
        x[i] = 1.0f;
    }

    cudaEvent_t start;
    cudaEvent_t stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    float first_scalar_mul = ScalarMulSumPlusReduction(N, x, x, blockSize);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    WriteToFile("data/05-scalar-1red.txt", N, blockSize, milliseconds);
    cudaEventRecord(start);

    float second_scalar_mul = ScalarMulTwoReductions(N, x, x, blockSize);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaEventElapsedTime(&milliseconds, start, stop);

    WriteToFile("data/05-scalar-2red.txt", N, blockSize, milliseconds);

    free(x);
    return 0;
}