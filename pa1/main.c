#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define BUFFER_TAM 1024

void
err(const char *msg, const char *perror_msg) {
    fprintf(stderr, "Error: %s\n", msg);
    perror(perror_msg);

    exit(EXIT_FAILURE);
}

void
cp_data(const int fd_in, const int fd_out) {
    ssize_t bytes_leidos = 0;
    ssize_t bytes_escritos = 0;
    char buffer[BUFFER_TAM] = {0};

    while ((bytes_leidos = read(fd_in, buffer, BUFFER_TAM)) > 0) {
        bytes_escritos = write(fd_out, buffer, (size_t)bytes_leidos);
        if (bytes_escritos == -1) {
            err("No se pudo escribir en fd_out", "write");
        }
    }

    if (bytes_leidos == -1) {
        err("No se pudo leer en fd_in", "read");
    }
}

int
main(int argc, char **argv) {
    int fd = -1;
    if (argc > 2) {
        fprintf(stderr, "Uso: mycat [ARCHIVO]\n");
        return EXIT_FAILURE;
    }

    /* stdin */
    if (argc == 1) {
        cp_data(STDIN_FILENO, STDOUT_FILENO);

        return EXIT_SUCCESS;
    }

    /* archivo */
    fd = open(argv[1], O_RDONLY);
    if (fd == -1) {
        err("Error al abrir el archivo", "open");
    }

    cp_data(fd, STDOUT_FILENO);

    if (close(fd) == -1) {
        err("Error al cerrar el archivo", "close");
    };

    return EXIT_SUCCESS;
}
