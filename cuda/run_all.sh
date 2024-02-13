#!/bin/bash

export CUDA_VISIBLE_DEVICES=3

chmod +x scripts/01-add.sh
chmod +x scripts/02-mul.sh
chmod +x scripts/03-matrix-add.sh
chmod +x scripts/04-matrix-vector-mul.sh
chmod +x scripts/05-scalar-mul.sh
chmod +x scripts/06-cosine-vector.sh
chmod +x scripts/07-matrix-mul.sh

./scripts/01-add.sh
./scripts/02-mul.sh
./scripts/03-matrix-add.sh
./scripts/04-matrix-vector-mul.sh
./scripts/05-scalar-mul.sh
./scripts/06-cosine-vector.sh
./scripts/07-matrix-mul.sh