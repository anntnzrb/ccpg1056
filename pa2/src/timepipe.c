#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#include "../include/common.h"

int
main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <comando> [args...]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    int pipefd[2];
    if (pipe(pipefd) == -1) {
        die("pipe");
    }

    const pid_t pid = fork();
    if (pid == -1) {
        die("fork");
    }

    if (pid == 0) {       // child proc
        close(pipefd[0]); // close pipe

        struct timeval start_time;
        obtener_tiempo(&start_time);

        // escribir en el pipe el tiempo de inicio
        if (write(pipefd[1], &start_time, sizeof(start_time)) == -1) {
            die("write");
        }
        close(pipefd[1]); // close pipe

        if (RUN_CMD(argv[1], &argv[1]) == -1) {
            die("exec");
        }

    } else {              // parent proc
        close(pipefd[1]); // close pipe

        struct timeval start_time, end_time;

        // leer del pipe el tiempo de inicio
        if (read(pipefd[0], &start_time, sizeof(start_time)) == -1) {
            die("read");
        }
        close(pipefd[0]); // close pipe

        // esperar a que el hijo termine
        wait(NULL);
        obtener_tiempo(&end_time);

        double elapsed = calcular_tiempo_transcurrido(start_time, end_time);
        printf("Tiempo transcurrido: %.6f segundos\n", elapsed);
    }

    return 0;
}
