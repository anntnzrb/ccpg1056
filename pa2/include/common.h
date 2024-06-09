#ifndef COMMON_H
#define COMMON_H

#include <sys/time.h>

// macro de conveniencia para ejecutar un comando
#define RUN_CMD(cmd, args) execvp(cmd, args)

// time struct
typedef struct {
    struct timeval start_time;
    struct timeval end_time;
} shared_data_t;

// fn para obtener el tiempo actual
void
obtener_tiempo(struct timeval *val);

// fn para calcular el tiempo transcurrido
double
calcular_tiempo_transcurrido(struct timeval start, struct timeval end);

// fn para imprimir un mensaje de error y terminar el programa
void
die(const char *msg);

#endif // COMMON_H
