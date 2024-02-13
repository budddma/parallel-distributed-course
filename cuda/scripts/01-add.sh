#!/bin/bash

for blockSize in 64 128 256 512 1024
do
	for ((i=1;i<25;i++))
	do 
		N=$((2**$i))
		./build/01-add $blockSize $N
	done
done