#!/bin/bash
#
#SBATCH --ntasks=8 # кол-во потоков
#SBATCH --cpus-per-task=2 # Кол-во задач на процессор/машину
#SBATCH --partition=RT_study # группа машин кластера
#SBATCH --job-name="budddma" # Имя задачи для очереди
#SBATCH --comment="yet another task" # Крайне обязательный пункт, без него придёт автокил
#SBATCH --output=out.txt # Файл для печати вывода
#SBATCH --error=error.txt # Файл для печати ошибок

for N in 1000 1000000 100000000
do
    for p in 1 2 3 4 5 6 7 8
    do
        mpiexec -np $p ./a.out $N
    done
done