#!/bin/bash

for blockSize in 64 128 256 512 1024
do
	for ((i=1;i<20;i++))
	do 
		N=$((2**$i))
		./build/06-cosine-vector $blockSize $N
	done
done