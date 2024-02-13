#!/bin/bash

for blockSize in 64 128 256 512 1024
do
	for ((i=1;i<20;i++))
	do 
		N=$((2**$i))
		M=$((2**7))
		./build/04-matrix-vector-mul $blockSize $N $M
	done
done