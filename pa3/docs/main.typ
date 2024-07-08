#import "@preview/sourcerer:0.2.1": code
#import "template.typ": *

#show: project.with(
  title: "PA3: Programación Multi-Hilos", authors: (
    (
      name: "Juan Antonio González", email: "juangonz@espol.edu.ec", affiliation: "ESPOL (FIEC)",
    ),
  ),
)

= Problemática a Resolver
La problemática de esta tarea se centra en el procesamiento de imágenes mediante
la lectura y escritura de archivos binarios, específicamente en el formato
*BMP*. A continuación se presentan varios objetivos y desafíos, entre ellos:

- Lectura y escritura de archivos binarios
- Manipulación de imágenes *BMP*
- Programación multihilos

El objetivo es desarrollar un programa que pueda leer una imagen *BMP*, aplicar
filtros (blur o desenfoque) utilizando programación multihilos y escribir la
imagen resultante en un nuevo archivo *BMP*. Posterior a esto se realizará una
comparación con una imágen de solución adjunta para corroborar la correctitud
del programa.

= Limitaciones y Resoluciónes
Durante el desarrollo del proyecto se presentaron aalgunas limitaciones, cada
una de las cuales requirió soluciones específicas para garantizar que el
programa funcione como fue originalmente intencionado.

== Gestión de Memoria
Trabajar con memoria en *C* es algo trabajoso y requiere bastante atención para
evitar errores como fugas de memoria y corrupción de datos. Se implementaron las
prácticas de gestión de memoria adecuadas, asegurando que toda la memoria
asignada se libere correctamente después de su uso. Se realizaron pruebas de
memoria para identificar y corregir cualquier fuga, utilizando la receta de
Makefile `testmem` ya adjunta en el proyecto.

== Pruebas y Validación
Al tener solo un caso de prueba proporcionado, era difícil determinar si el
trabajo estaba completamente terminado o si podría fallar en otros escenarios.
Lo que se hizo fue comparar de forma visual las imágenes, comparando la de
solución con la generada para asegurarse de que los resultados fueran correctos.

== Manipulación de Imágenes BMP
El formato BMP almacena información detallada de cada píxel, lo que puede hacer
que la manipulación de imágenes sea intensiva en términos de procesamiento.
Pensar en tres dimensiones para manipular matrices de píxeles no fue fácil,
implementar bucles `for` anidados, a veces dobles o triples, fue un desafío.

Para abordar la complejidad de los bucles anidados, y a pesar de que no es una
solución per-se, se agregaron cuidadosamente comentarios detallados en el código
para facilitar la comprensión y el mantenimiento.

#pagebreak()

= Salidas de Pantalla y Ejecución
#figure(
  image("assets/cap_test.png", width: 60%), caption: "Test positivo de la app",
)

#figure(
  image("assets/cap_comp.png", width: 100%), caption: "Comparativa visual entre imágenes",
)

En esta captura es difícil ver la diferencia entre las imágenes. En la parte
izquierda se encuentra la imágen original, en la esquina superior derecha la
solución y justo debajo (esquina inferior derecha) se encuentra la imágen
generada por el programa, la cual es idéntica a la solución directamente en la
parte de arriba de esta.

#pagebreak()

= Anexos
En las secciones de código adjunto se han incluido secciones parciales del
código fuente. Esto para destacar los fragmentos más destacados, sin embargo
estos no representan la totalidad del código fuente y por propósitos de
simplicidad han sido simplificados hasta cierto punto. Para ver el código
completo se recomienda revisar el repositorio de GitHub y/o archivos adjuntos.

== Código Fuente de `bmp.c`
#code(
  lang: "C", ```c
        BMP_Image *createBMPImage(FILE *fptr) {
            BMP_Image *image = malloc(sizeof(BMP_Image));
            if (image == NULL) {
                return NULL;
            }

            if (fread(&(image->header), sizeof(BMP_Header), 1, fptr) != 1) {
                free(image);
                return NULL;
            }

            int width_px = image->header.width_px;
            int height_px = abs(image->header.height_px);

            image->bytes_per_pixel = image->header.bits_per_pixel / 8;
            image->norm_height = height_px;

            image->pixels = malloc(height_px * sizeof(Pixel *));
            if (image->pixels == NULL) {
                free(image);
                return NULL;
            }

            for (int i = 0; i < height_px; i++) {
                image->pixels[i] = malloc(width_px * sizeof(Pixel));
                if (image->pixels[i] == NULL) {
                    for (int j = 0; j < i; j++) {
                        free(image->pixels[j]);
                    }

                    free(image->pixels);
                    free(image);
                    return NULL;
                }
            }

            return image;
        }

        void readImageData(FILE *srcFile, BMP_Image *image, int dataSize) {
            for (int i = 0; i < image->norm_height; i++) {
                for (int j = 0; j < image->header.width_px; j++) {
                    if (fread(&image->pixels[i][j], dataSize, 1, srcFile) != 1) {
                        printError(MEMORY_ERROR);
                        exit(EXIT_FAILURE);
                    }
                }
            }
        }

        void readImage(FILE *srcFile, BMP_Image *dataImage) {
            BMP_Image *image = createBMPImage(srcFile);
            if (image == NULL) {
                printError(MEMORY_ERROR);
                exit(EXIT_FAILURE);
            }

            *dataImage = *image;

            free(image);

            readImageData(srcFile, dataImage, dataImage->bytes_per_pixel);
        }

        void writeImage(char *destFileName, BMP_Image *dataImage) {
            FILE *destFile = fopen(destFileName, "wb");
            if (destFile == NULL) {
                printError(FILE_ERROR);
                exit(EXIT_FAILURE);
            }

            if (fwrite(&(dataImage->header), sizeof(BMP_Header), 1, destFile) != 1) {
                printError(MEMORY_ERROR);
                exit(EXIT_FAILURE);
            }

            for (int i = 0; i < dataImage->norm_height; i++) {
                if (fwrite(dataImage->pixels[i], sizeof(Pixel),
                           dataImage->header.width_px,
                           destFile) != (size_t)dataImage->header.width_px) {
                    printError(MEMORY_ERROR);
                    exit(EXIT_FAILURE);
                }
            }

            fclose(destFile);
        }

        void freeImage(BMP_Image *image) {
            for (int i = 0; i < image->norm_height; i++) {
                free(image->pixels[i]);
            }

            free(image->pixels);
            free(image);
        }

        void transBMP(BMP_Image *image, BMP_Image *new_image) {
            memcpy(&(new_image->header), &(image->header), sizeof(BMP_Header));

            if (image->header.bits_per_pixel == 24) {
                new_image->header.bits_per_pixel = 32;
                new_image->header.imagesize =
                    image->norm_height * image->header.width_px * 4;
                new_image->header.size =
                    new_image->header.imagesize + sizeof(BMP_Header);
                new_image->bytes_per_pixel = 4;
            } else if (image->header.bits_per_pixel == 32) {
                new_image->bytes_per_pixel = image->bytes_per_pixel;
            }

            new_image->norm_height = image->norm_height;

            new_image->pixels = malloc(new_image->norm_height * sizeof(Pixel *));
            if (new_image->pixels == NULL) {
                printError(MEMORY_ERROR);
                exit(EXIT_FAILURE);
            }

            for (int i = 0; i < image->norm_height; i++) {
                new_image->pixels[i] = malloc(image->header.width_px * sizeof(Pixel));
                if (new_image->pixels[i] == NULL) {
                    for (int j = 0; j < i; j++) {
                        free(new_image->pixels[j]);
                    }
                    free(new_image->pixels);
                    printError(MEMORY_ERROR);
                    exit(EXIT_FAILURE);
                }
            }
        }
          ```,
)

#pagebreak()

== Código Fuente de `filter.c`
#code(
  lang: "C", ```c
      int boxFilter[FILTER_SIZE][FILTER_SIZE] = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}};

      int calcPixelVal(Pixel **imagePixels, int posX, int posY, int imgWidth,
                   int imgHeight, RGBChannel color) {
          int pixelValue = 0;
          for (int offsetX = 0; offsetX < FILTER_SIZE; offsetX++) {
              for (int offsetY = 0; offsetY < FILTER_SIZE; offsetY++) {
                  int adjustedX = posX - FILTER_SIZE / 2 + offsetX;
                  int adjustedY = posY - FILTER_SIZE / 2 + offsetY;

                  adjustedX = MAX(0, MIN(adjustedX, imgHeight - 1));
                  adjustedY = MAX(0, MIN(adjustedY, imgWidth - 1));

                  switch (color) {
                  case RED:
                      pixelValue += imagePixels[adjustedX][adjustedY].red *
                                    boxFilter[offsetX][offsetY];
                      break;
                  case GREEN:
                      pixelValue += imagePixels[adjustedX][adjustedY].green *
                                    boxFilter[offsetX][offsetY];
                      break;
                  case BLUE:
                      pixelValue += imagePixels[adjustedX][adjustedY].blue *
                                    boxFilter[offsetX][offsetY];
                      break;
                  }
              }
          }

          return pixelValue;
      }

      void apply(BMP_Image *imageIn, BMP_Image *imageOut, int startRow, int endRow) {
          for (int row = startRow; row < endRow; row++) {
              for (int col = 0; col < imageIn->header.width_px; col++) {
                  imageOut->pixels[row][col].red =
                      calcPixelVal(imageIn->pixels, row, col,
                                   imageIn->header.width_px, imageIn->norm_height,
                                   RED) /
                      (FILTER_SIZE * FILTER_SIZE);
                  imageOut->pixels[row][col].green =
                      calcPixelVal(imageIn->pixels, row, col,
                                   imageIn->header.width_px, imageIn->norm_height,
                                   GREEN) /
                      (FILTER_SIZE * FILTER_SIZE);
                  imageOut->pixels[row][col].blue =
                      calcPixelVal(imageIn->pixels, row, col,
                                   imageIn->header.width_px, imageIn->norm_height,
                                   BLUE) /
                      (FILTER_SIZE * FILTER_SIZE);
                  imageOut->pixels[row][col].alpha = 255;
              }
          }
      }

      void applyParallel(BMP_Image *imageIn, BMP_Image *imageOut, int numThreads) {
          printf("Applying filter with %d threads\n", numThreads);

          pthread_t *threads = malloc(numThreads * sizeof(pthread_t));
          parameters *params = malloc(numThreads * sizeof(parameters));

          const int height_px = imageIn->norm_height;
          const int rowsPerThread = height_px / numThreads;
          int remainingRows = height_px % numThreads;
          int startRow = 0;
          int endRow;

          for (int i = 0; i < numThreads; i++) {
              endRow = startRow + rowsPerThread;

              if (remainingRows > 0) {
                  endRow = endRow + 1;
                  remainingRows = remainingRows - 1;
              }

              params[i] = (parameters){.imageIn = imageIn,
                                       .imageOut = imageOut,
                                       .startRow = startRow,
                                       .endRow = endRow};

              pthread_create(&threads[i], NULL, filterThreadWorker, &params[i]);

              startRow = endRow;
          }

          for (int i = 0; i < numThreads; i++) {
              pthread_join(threads[i], NULL);
          }

          free(threads);
          free(params);
      }

      void *filterThreadWorker(void *args) {
          parameters *params = (parameters *)args;
          apply(params->imageIn, params->imageOut, params->startRow, params->endRow);

          return NULL;
      }
        ```,
)

#pagebreak()

#bibliography("bib.bib", style: "ieee", full: true, title: "Referencias")
