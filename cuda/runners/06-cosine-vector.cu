#include <CosineVector.cuh>
#include <iostream>
#include <CommonKernels.cuh>

int main(int argc, char** argv) {
    int blockSize = atoi(argv[1]);
    int N = atoi(argv[2]);

    size_t size = N * sizeof(float);

    float *x = (float*)malloc(size);
    float *y = (float*)malloc(size);

    for (int i = 0; i < N; ++i) {
        x[i] = 1.0f;
        y[i] = -1.0f;
    }

    cudaEvent_t start;
    cudaEvent_t stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    float cos_angle = CosineVector(N, x, y, blockSize);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    WriteToFile("data/06-cosine-vector.txt", N, blockSize, milliseconds);

    free(x);
    free(y);
    return 0;

}
