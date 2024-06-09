#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "../include/common.h"

void
obtener_tiempo(struct timeval *val) {
    gettimeofday(val, NULL);
}

double
calcular_tiempo_transcurrido(struct timeval start, struct timeval end) {
    long seconds = end.tv_sec - start.tv_sec;
    long microseconds = end.tv_usec - start.tv_usec;
    return (double)seconds + (double)microseconds * 1e-6;
}

void
die(const char *msg) {
    perror(msg);
    exit(EXIT_FAILURE);
}
