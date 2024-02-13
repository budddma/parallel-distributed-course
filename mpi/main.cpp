#include <mpi.h>
#include <math.h>
#include <iostream>
#include <fstream>


double f(double x) {
    return 4.0 / (1 + x*x);
}

double intergral(double a, int dx_count, double dx) {
    double sum = 0.0;
    for (int i = 1; i <= dx_count; i++) {
        double x1 = a + (i - 1) * dx;
        double x2 = a + i * dx;
        sum += (f(x1) + f(x2)) / 2 * dx;
    }
    return sum;
}

void write(int N, int p, double S) {
    std::fstream outfile;
    outfile.open("data.txt", std::ios::out | std::ios::app);
    outfile << N << ' ' << p << ' ' << S << '\n';
    outfile.close();
}

int main(int argc, char *argv[]) {
    int N = atoi(argv[1]);
    int p, rank;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &p);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    double a = 0.0, b = 1.0;
    double dx = (b - a) / N;
    int dx_per_proc = N / p;
    int extra_dx = N % p;
    double a_i = a + rank * dx_per_proc * dx;

    double start = MPI_Wtime();
    double I_i = 0.0;
    if (rank != p - 1) {
        I_i = intergral(a_i, dx_per_proc, dx);
    } else {
        I_i = intergral(a_i, dx_per_proc + extra_dx, dx);
    }

    if (rank != 0) {
        MPI_Send(&I_i, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
    } else {
        double I = I_i;
        std::cout << "N = " << N << ", p = " <<  p << std::endl;
        std::cout << 1 << ") I_i = " << I_i << std::endl;
        for (int i = 1; i < p; i++) {
            MPI_Recv(&I_i, 1, MPI_DOUBLE, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            std::cout << i + 1 << ") I_i = " << I_i << std::endl;
            I += I_i;
        }
        double time = MPI_Wtime() - start;
        std::cout << "I = " << I << std::endl;

        double start_0 = MPI_Wtime();
        double I_0 = intergral(a_i, N, dx);
        double time_0 = MPI_Wtime() - start_0;
        std::cout << "I_0 = " << I_0 << " (отличие от I на " << abs(I - I_0) / I * 100 << "%)" << std::endl;

        std::cout << "-------------------------------------------\n";
        write(N, p, time_0 / time);
    }

    MPI_Finalize();
    return 0;
}
