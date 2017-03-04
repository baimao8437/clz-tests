#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "clz.h"

#if defined(RECURSIVE)
#define clz(x) clz2(x,0)
#endif

#define CLOCK_ID CLOCK_MONOTONIC_RAW
#define ONE_SEC 1000000000.0

int main(int argc, char const *argv[])
{
    struct timespec start = {0, 0};
    struct timespec end = {0, 0};

    int error = 0;

    for (uint32_t i = 0; i < 32; i++) {
        error = 0;
        clock_gettime(CLOCK_ID, &start);
        for (uint32_t j = (1 << i); j < (1 << (i + 1)); j++) {
            if (__builtin_clz(j) != clz(j))
                error++;
        }
        clock_gettime(CLOCK_ID, &end);

        printf("%d,%lf,", error, (double)(end.tv_sec - start.tv_sec) +
               (end.tv_nsec - start.tv_nsec) / ONE_SEC);
    }

    return 0;
}
