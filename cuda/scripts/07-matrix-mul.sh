#!/bin/bash

for blockSize in 64 128 256 512 1024
do
	for ((i=1;i<10;i++))
	do 
		N=$((2**$i))
		M=$((2**7))
		K=$((2**5))
		./build/07-matrix-mul $blockSize $N $M $K
	done
done