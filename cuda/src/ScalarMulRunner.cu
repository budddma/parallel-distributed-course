#include <ScalarMulRunner.cuh>
#include <KernelMul.cuh>
#include <ScalarMul.cuh>
#include <CommonKernels.cuh>


float ScalarMulTwoReductions(int numElements, float* vector1, float* vector2, int blockSize) {
  int numBlocks = (numElements + blockSize - 1) / blockSize;
  float* result = (float*)calloc(blockSize, sizeof(float));

  float* d_vec1 = nullptr;
  float* d_vec2 = nullptr;
  float* d_vec_mul = nullptr;
  float* d_result = nullptr;

  cudaMalloc(&d_vec1, numElements * sizeof(float));
  cudaMalloc(&d_vec2, numElements * sizeof(float));
  cudaMalloc(&d_vec_mul, numElements * sizeof(float));
  cudaMalloc(&d_result, numBlocks * sizeof(float));

  cudaMemcpy(d_vec1, vector1, numElements * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_vec2, vector2, numElements * sizeof(float), cudaMemcpyHostToDevice);

  KernelMul<<<numBlocks, blockSize>>>(numElements, d_vec1, d_vec2, d_vec_mul);

  int remainderSize = numElements;

  while (numBlocks > 1) {
    ReduceSum<<<numBlocks, blockSize, blockSize * sizeof(float)>>>(remainderSize,
                                                                    d_vec_mul,
                                                                    d_result);
    cudaMemcpy(d_vec_mul, d_result, numBlocks * sizeof(float), cudaMemcpyDeviceToDevice);

    remainderSize = numBlocks;
    numBlocks = (numBlocks + blockSize - 1) / blockSize;
  }

  ReduceSum<<<1, blockSize, blockSize * sizeof(float)>>>(remainderSize, d_vec_mul, d_result);
  float sum = 0.0f;
  cudaMemcpy(&sum, d_result, sizeof(float), cudaMemcpyDeviceToHost);

  cudaFree(d_vec1);
  cudaFree(d_vec2);
  cudaFree(d_vec_mul);
  cudaFree(d_result);
  free(result);

  return sum;
}

float ScalarMulSumPlusReduction(int numElements, float* vector1, float* vector2, int blockSize) {
  int numBlocks = (numElements + blockSize - 1) / blockSize;

  float* d_vec1 = nullptr;
  float* d_vec2 = nullptr;
  float* d_vec_mul = nullptr;
  float* d_result = nullptr;

  cudaMalloc(&d_vec1, numElements * sizeof(float));
  cudaMalloc(&d_vec2, numElements * sizeof(float));
  cudaMalloc(&d_vec_mul, numElements * sizeof(float));
  cudaMalloc(&d_result, blockSize * sizeof(float));

  cudaMemcpy(d_vec1, vector1, numElements * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_vec2, vector2, numElements * sizeof(float), cudaMemcpyHostToDevice);

  KernelMul<<<numBlocks, blockSize>>>(numElements, d_vec1, d_vec2, d_vec_mul);
  SumBlocks<<<1, blockSize>>>(numElements, d_vec_mul, d_result);
  ReduceSum<<<1, blockSize, blockSize * sizeof(float)>>>(blockSize, d_result, d_vec_mul);

  float sum = 0.0f;
  cudaMemcpy(&sum, d_vec_mul, sizeof(float), cudaMemcpyDeviceToHost);

  cudaFree(d_vec1);
  cudaFree(d_vec2);
  cudaFree(d_vec_mul);
  cudaFree(d_result);

  return sum;
}