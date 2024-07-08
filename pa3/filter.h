#include "bmp.h"

#define FILTER_SIZE 3

typedef struct {
    BMP_Image *imageIn;
    BMP_Image *imageOut;
    int startRow;
    int endRow;
} parameters;

int
getPxlValue(Pixel **pixels, int x, int y, int channel);
void
handlePadding(BMP_Image *imageIn);

void
apply(BMP_Image *imageIn, BMP_Image *imageOut, int startRow, int endRow);
void
applyParallel(BMP_Image *imageIn, BMP_Image *imageOut, int numThreads);
void *
filterThreadWorker(void *args);
