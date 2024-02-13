#include <CosineVector.cuh>
#include <ScalarMulRunner.cuh>
#include <CommonKernels.cuh>
#include <KernelMul.cuh>

float CosineVector(int numElements, float* vector1, float* vector2, int blockSize) {
  int numBlocks = (numElements + blockSize - 1) / blockSize;
  float scalar_mul = ScalarMulTwoReductions(numElements, vector1, vector2, blockSize);

  float* d_vec1 = nullptr;
  float* d_vec1_sq = nullptr;
  float* d_vec2 = nullptr;
  float* d_vec2_sq = nullptr;
  
  cudaMalloc(&d_vec1, numElements * sizeof(float));
  cudaMalloc(&d_vec1_sq, numElements * sizeof(float));
  cudaMalloc(&d_vec2, numElements * sizeof(float));
  cudaMalloc(&d_vec2_sq, numElements * sizeof(float));

  cudaMemcpy(d_vec1, vector1, numElements * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_vec2, vector2, numElements * sizeof(float), cudaMemcpyHostToDevice);

  KernelMul<<<numBlocks, blockSize>>>(numElements, d_vec1, d_vec1, d_vec1_sq);
  KernelMul<<<numBlocks, blockSize>>>(numElements, d_vec2, d_vec2, d_vec2_sq);

  float* vec1_sq = (float*)calloc(numElements, sizeof(float));
  float* vec2_sq = (float*)calloc(numElements, sizeof(float));

  cudaMemcpy(vec1_sq, d_vec1_sq, numElements * sizeof(float), cudaMemcpyDeviceToHost);
  cudaMemcpy(vec2_sq, d_vec2_sq, numElements * sizeof(float), cudaMemcpyDeviceToHost);

  float vec1_norm_sq = Sum(numElements, vec1_sq, blockSize);
  float vec2_norm_sq = Sum(numElements, vec2_sq, blockSize);

  cudaFree(d_vec1);
  cudaFree(d_vec1_sq);
  cudaFree(d_vec2);
  cudaFree(d_vec2_sq);
  free(vec1_sq);
  free(vec2_sq);

  if (vec1_norm_sq == 0 || vec2_norm_sq == 0) {
    return 0.0f;
  }
  return scalar_mul / sqrt(vec1_norm_sq) / sqrt(vec2_norm_sq);
}

