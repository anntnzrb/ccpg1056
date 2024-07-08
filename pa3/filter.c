#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#include "bmp.h"
#include "filter.h"

// 2D array representing the filter that will be applied to the img
int boxFilter[FILTER_SIZE][FILTER_SIZE] = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}};

/* retrieve pixel channel val */
int
getPxlValue(Pixel **pixels, int x, int y, int channel) {
    int pixelValue = 0;
    // iter filter size
    for (int row = 0; row < FILTER_SIZE; row++) {
        for (int col = 0; col < FILTER_SIZE; col++) {
            // calc pixel position
            int pixelRow = x - FILTER_SIZE / 2 + row;
            int pixelCol = y - FILTER_SIZE / 2 + col;

            // add the corresponding color value depending on the channel
            if (channel == 0) { // R
                pixelValue +=
                    pixels[pixelRow][pixelCol].red * boxFilter[row][col];
            } else if (channel == 1) { // G
                pixelValue +=
                    pixels[pixelRow][pixelCol].green * boxFilter[row][col];
            } else { // B
                pixelValue +=
                    pixels[pixelRow][pixelCol].blue * boxFilter[row][col];
            }
        }
    }

    return pixelValue; // Return the calculated pixel value
}

/* handle padding for the img */
void
handlePadding(BMP_Image *imageIn) {
    // calc new width and height + padding
    const int paddedWidth = imageIn->header.width_px + 2;
    const int paddedHeight = imageIn->norm_height + 2;

    // mem for padded img
    Pixel **paddedImage = calloc(paddedHeight, sizeof(Pixel *));
    for (int row = 0; row < paddedHeight; row++) {
        paddedImage[row] = calloc(paddedWidth, sizeof(Pixel));

        // init padded img with black pixels (r, g, b = 0) and full alpha (255)
        for (int col = 0; col < paddedWidth; col++) {
            paddedImage[row][col] =
                (Pixel){.red = 0, .green = 0, .blue = 0, .alpha = 255};
        }
    }

    // cp original img into padded img
    for (int row = 0; row < imageIn->norm_height; row++) {
        for (int col = 0; col < imageIn->header.width_px; col++) {
            paddedImage[row + 1][col + 1] = imageIn->pixels[row][col];
        }
    }

    // replace original img pixels with padded img pixels
    imageIn->pixels = paddedImage;
}

void
apply(BMP_Image *imageIn, BMP_Image *imageOut, int startRow, int endRow) {
    // iterate over the img
    for (int i = startRow; i < endRow; i++) {
        for (int j = 1; j < imageIn->header.width_px + 1; j++) {
            imageOut->pixels[i - 1][j - 1] =
                (Pixel){.red = getPxlValue(imageIn->pixels, i, j, 0) /
                               (FILTER_SIZE * FILTER_SIZE),
                        .green = getPxlValue(imageIn->pixels, i, j, 1) /
                                 (FILTER_SIZE * FILTER_SIZE),
                        .blue = getPxlValue(imageIn->pixels, i, j, 2) /
                                (FILTER_SIZE * FILTER_SIZE),
                        .alpha = 255};
        }
    }
}

void
applyParallel(BMP_Image *imageIn, BMP_Image *imageOut, int numThreads) {
    printf("Applying filter with %d threads\n", numThreads);

    pthread_t *threads = malloc(numThreads * sizeof(pthread_t));
    parameters *params = malloc(numThreads * sizeof(parameters));

    // save original img pixels in a temp var and handle padding
    Pixel **temp = imageIn->pixels;
    handlePadding(imageIn);

    const int height_px = imageIn->norm_height;
    const int rowsPerThread = height_px / numThreads;
    int remainingRows = height_px % numThreads;
    int startRow = 1;
    int endRow;

    for (int i = 0; i < numThreads; i++) {
        // calc end row for current thread
        endRow = startRow + rowsPerThread;

        // if there are remaining rows, assign one more row to this thread and
        // decrement the count of remaining rows
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

    // wait for all threads to finish
    for (int i = 0; i < numThreads; i++) {
        pthread_join(threads[i], NULL);
    }

    for (int i = 0; i < height_px + 2; i++) {
        free(imageIn->pixels[i]);
    }
    free(imageIn->pixels);

    // restore original img pixels
    imageIn->pixels = temp;

    free(threads);
    free(params);
}

void *
filterThreadWorker(void *args) {
    parameters *params = (parameters *)args;

    apply(params->imageIn, params->imageOut, params->startRow, params->endRow);

    return NULL;
}
