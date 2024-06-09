#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <unistd.h>

#include "../include/common.h"

int
main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <comando> [args...]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    // crear shared mem
    shared_data_t *shared_data =
        mmap(NULL, sizeof(shared_data_t), PROT_READ | PROT_WRITE,
             MAP_SHARED | MAP_ANONYMOUS, -1, 0);
    if (shared_data == MAP_FAILED) {
        die("mmap");
    }

    const pid_t pid = fork();
    if (pid == -1) {
        die("fork");
    }

    if (pid == 0) { // child proc
        obtener_tiempo(&shared_data->start_time);
        if (RUN_CMD(argv[1], &argv[1]) == -1) {
            die("exec");
        }
    } else { // parent proc
        wait(NULL);
        obtener_tiempo(&shared_data->end_time);

        const double elapsed = calcular_tiempo_transcurrido(
            shared_data->start_time, shared_data->end_time);
        printf("Tiempo transcurrido: %.6f segundos\n", elapsed);

        // free shared mem
        if (munmap(shared_data, sizeof(shared_data_t)) == -1) {
            die("munmap");
        }
    }

    return EXIT_SUCCESS;
}
