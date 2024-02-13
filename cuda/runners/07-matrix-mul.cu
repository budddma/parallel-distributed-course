#include <MatrixMul.cuh>
#include <CommonKernels.cuh>

int main(int argc, char** argv) {
    int blockSize1D = atoi(argv[1]);
    int aHeight = atoi(argv[2]);
    int aWidth = atoi(argv[3]);
    int bWidth = atoi(argv[4]);
    int bHeight = aWidth;

    size_t aN = aHeight * aWidth;
    size_t bN = bHeight * bWidth;
    size_t resN = aHeight * bWidth;

    size_t aSize = aN * sizeof(float);
    size_t bSize = bN * sizeof(float);
    size_t resSize = resN * sizeof(float);

    float *a = (float*)malloc(aSize);
    float *b = (float*)malloc(bSize);
    float *res = (float*)malloc(resSize);

    FillData(a, aN);
    FillData(b, bN, 2.0f);

    size_t a_pitch = 0;
    size_t b_pitch = 0;
    size_t res_pitch = 0;
    float *d_a = nullptr;
    float *d_b = nullptr;
    float *d_res = nullptr;

    cudaMallocPitch(&d_a, &a_pitch, aWidth * sizeof(float), aHeight);
    cudaMallocPitch(&d_b, &b_pitch, bWidth * sizeof(float), bHeight);
    cudaMallocPitch(&d_res, &res_pitch, bWidth * sizeof(float), aHeight);

    cudaMemcpy2D(d_a, a_pitch, a, aWidth * sizeof(float), aWidth * sizeof(float), aHeight,
                 cudaMemcpyHostToDevice);
    cudaMemcpy2D(d_b, b_pitch, b, bWidth * sizeof(float), bWidth * sizeof(float), bHeight,
                 cudaMemcpyHostToDevice);

    cudaEvent_t start;
    cudaEvent_t stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    int numXBlocks = (res_pitch / sizeof(float) + blockSize1D - 1) / blockSize1D;
    int numYBlocks = (aHeight + blockSize1D - 1) / blockSize1D;
    int blockSizeInBytes = blockSize1D * blockSize1D * sizeof(float);

    dim3 numBlocks(numXBlocks, numYBlocks);
    dim3 blockSize(blockSize1D, blockSize1D);

    MatrixMul<<<numBlocks, blockSize, blockSizeInBytes * 2>>>(aHeight,
                                                                a_pitch / sizeof(float),
                                                                b_pitch / sizeof(float),
                                                                d_a,
                                                                d_b,
                                                                d_res);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    cudaMemcpy2D(res, bWidth * sizeof(float), d_res, res_pitch, bWidth * sizeof(float), aHeight,
                 cudaMemcpyDeviceToHost);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    WriteToFile("data/07-matrix-mul.txt",
                aWidth * aHeight * bWidth,
                blockSize1D,
                milliseconds);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_res);

    free(a);
    free(b);
    free(res);
    return 0;
}