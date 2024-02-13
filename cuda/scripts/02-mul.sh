#!/bin/bash

for blockSize in 64 128 256 512 1024
do
	for ((i=1;i<25;i++))
	do 
		N=$((2**$i))
		./build/02-mul $blockSize $N
	done
done