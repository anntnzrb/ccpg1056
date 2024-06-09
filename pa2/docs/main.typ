#import "@preview/sourcerer:0.2.1": code
#import "template.typ": *

#show: project.with(
  title: "PA2: Comunicación entre Procesos IPC", authors: (
    (
      name: "Juan Antonio González", email: "juangonz@espol.edu.ec", affiliation: "ESPOL (FIEC)",
    ),
  ),
)

= Problemática a Resolver
En este trabajo se solicitó diseñar y desarrollar dos programas en *C* (`timeshmm.c` y `timepipe.c`)
que calculen el tiempo de ejecución de un comando especificado desde la línea de
comandos. Los programas deben gestionar la comunicación entre procesos usando
dos técnicas diferentes de IPC: *Shared Memory* y *Pipes*.

#figure(
  image("assets/cap_demo.png", width: 90%), caption: "Ejecución del programa con el comando ls",
)

= Limitaciones y Resoluciónes
En el desarrollo de los programas se identificaron varias limitaciones
relacionadas con la comunicación entre procesos y la precisión en la medición
del tiempo. A continuación, se describen estas limitaciones y las resoluciones
implementadas en los archivos adjuntos.

== Manejo de Errores en la Comunicación
- *Limitación*: La comunicación entre procesos puede fallar debido a varios
  motivos, fallos en la creación de shared memory o pipe, fallos en
  `fork()` o `exec()`, entre otros problemas de sincronización.

- *Resolución*: Se implementó manejo de errores en ambos programas. Se verifican
  los resultados de las llamadas a `shmget()`, `shmat()`, `pipe()`,
  `fork()`, y `exec()`. Si alguna de estas llamadas falla, el programa imprime un
  mensaje de error y termina correctamente.

== Precisión de la Medición del Tiempo
- *Limitación*: La función `gettimeofday()` empleada tiene una precisión limitada
  a microsegundos, lo que puede no ser suficiente para comandos de muy corta
  duración o en sistemas con alta carga de procesos

- *Resolución*: No se puede aumentar la precisión de `gettimeofday()`, pero se
  optó por registrar los tiempos minimizando el código entre las llamadas a esta
  función y la ejecución del comando

#pagebreak()

== Uso de Recursos del Sistema
- *Descripción*: El uso excesivo de recursos del sistema (shard memoory o pipes)
  puede afectar el rendimiento del sistema y la precisión de las mediciones.

- *Resolución*: La shared memory y las pipes se crean y destruyen al finalizar su
  trasbajo. En `timeshmm.c`, se libera la shared memory al finalizar la lectura
  del proceso padre. En `timepipe.c`, se cierran las pipes adecuadamente después
  de la lectura y escritura de los datos.

== Redundancia y Mantenimiento del Código
- *Descripción*: Durante la implementación se identificaron partes del código que
  eran muy repetitivas, por lo que se optó por reorganizar el código para reducir
  la redundancia y facilitar el mantenimiento.

- *Resolución*: Se creó un archivo común (`common.c` y `common.h`) donde se
  agruparon las funciones y definiciones compartidas entre ambos programas. Esta
  organización no solo reduce la redundancia sino que también facilita el
  mantenimiento y la comprensión del código al lector.

#pagebreak()

= Salidas de Pantalla y Ejecución
#figure(
  image("assets/cap_grep.png", width: 90%), caption: "Ejecución de timeshmm y timepipe con el comando grep (con argumentos)",
)

#figure(
  image("assets/cap_du.png", width: 90%), caption: "Ejecución de timeshmm y timepipe con el comando du (con argumentos)",
)

Los resultados de las pruebas muestran que ambos programas son capaces de medir
correctamente el tiempo de ejecución de comandos con múltiples argumentos. Las
diferencias en los tiempos medidos son mínimas y pueden atribuirse a la
precisión de la función `gettimeofday()` y a la carga del sistema en el momento
de la ejecución.

#pagebreak()

= Anexos
== Código Fuente de `timeshmm.c`
#code(lang: "C", ```c
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
  ```)

#pagebreak()

== Código Fuente de `timepipe.c`
#code(
  lang: "C", ```c
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
    ```,
)

#pagebreak()

== Código Fuente de `common.h` y `common.c`
#code(lang: "C", ```c
// common.h
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
  ```)

#code(lang: "C", ```c
// common.c
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
  ```)

#pagebreak()

#bibliography("bib.bib", full: true, style: "ieee")
