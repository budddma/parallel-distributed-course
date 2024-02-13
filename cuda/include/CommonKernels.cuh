#pragma once

const int maxBlocks = 1024;

void WriteToFile(const char* filename, const int data_size,
                    const int block_size, const double time);

void FillData(float* data, int size, float value = 1.0f);

__global__ void ReduceSum(int numElements, float* input, float* output);

__global__ void SumBlocks(int numElements, float* input, float* result);

float Sum(int numElements, float* vector, int blockSize);