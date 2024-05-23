#import "@preview/sourcerer:0.2.1": code
#import "template.typ": *

#show: project.with(
  title: "PA1: Uso de Syscalls", authors: (
    (
      name: "Juan Antonio González", email: "juangonz@espol.edu.ec", affiliation: "ESPOL (FIEC)",
    ),
  ),
)

= Problemática a Resolver
El objetivo de esta práctica es desarrollar una aplicación de línea de comandos
similar a `cat`. Para este trabajo, se le ha denominado `mycat.` El programa
`mycat` debe aceptar un archivo como argumento, leer su contenido y escribirlo
en `stdout`. Así mismo, si un archivo no es provisto, el programa debe leer a
través de `stdin`, cumpliendo con el mismo objetivo.

Como limitante se ha impuesto el empleo de funciones wrapper de POSIX para la
implementación de este programa. La implementación debe hacer uso exclusivo de
las funciones `open()`, `read()` y `write()`, asegurando un manejo adecuado de
errores.

= Limitaciones y Resoluciones

== Uso Exclusivo de Funciones POSIX
La restricción de utilizar únicamente las funciones descritas anteriormente
impuso una gran limitación, ya que se tuvo que evitar el uso de funciones
estándar de la biblioteca *C*, tales como `fopen()`, `fread()` y `fwrite()`.
Estas funciones de prefijo "f" ofrecen un nivel más alto de abstracción y manejo
automático de buffers, simplificando la implementación de este programa.

Teniendo esto presente, se implementó un manejo de errores adecuado para cada
llamada de las funciones POSIX. Se emplearon distintas funciones, como
`perror()` para señalizar mensajes claros y detallados. El programa en si es
bastante simple, hasta el punto de poder abstraer la lógica de leer y escribir
un descriptor de archivo.

#pagebreak()

La abstracción de la lógica de lectura y escritura de un descriptor de archivo
fue compartida para los casos en donde se aceptaban argumentos de línea de
comandos y también para los casos en donde se leía un archivo.

A continuación se muestra la función `cp_data()` que se encarga de leer y
escribir un descriptor de archivo:

#code(lang: "C", ```c
  #define BUFFER_TAM 1024

  static void
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
  ```)

Esta función copia datos en bloques de un tamaño definido por `BUFFER_TAM`,
desde un archivo identificado por `fd_in` hacia otro archivo identificado por
`fd_out`. El programa completo es más elaborado, sin embargo se resalta esta
función en específico por su importancia en la implementación de `mycat`.

#pagebreak()

= Capturas de Pantalla

#figure(image("assets/cap1.png", width: 90%), caption: "mycat: archivo existe")

#figure(
  image("assets/cap2.png", width: 90%), caption: "mycat: archivo inexiste",
)

#figure(
  image("assets/cap3.png", width: 90%), caption: "mycat: sin argumentos de cmd",
)

#figure(image("assets/cap4.png", width: 90%), caption: "mycat: archivo vacío")

#figure(
  image("assets/cap5.png", width: 90%), caption: "mycat: redirección de stdin",
)

//#bibliography("bib.bib", full: true, style: "apa")
