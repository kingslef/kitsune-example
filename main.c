#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>

#include <unistd.h>
#include <signal.h>

#include <kitsune.h>

static const unsigned int sleeptime = 5;

#ifndef N_DATA_ELEMENTS
#define N_DATA_ELEMENTS (20971520u)
#endif

data_t *E_PTRARRAY(N_DATA_ELEMENTS) synchronized_data;

static int DO_EXIT = 0;

static void exit_signal_handler(int sig)
{
    sig = sig;

    DO_EXIT = 1;
}

static void initialize_synchronized_data(data_t *data)
{
    for (uint32_t i = 0; i < N_DATA_ELEMENTS; i++) {
        data[i] = (data_t){ .a = (uint32_t)rand(), .b = (uint32_t)rand() };
    }
}

int main(void) E_NOTELOCALS
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));

    sa.sa_handler = exit_signal_handler;
    sigemptyset(&sa.sa_mask);

    if (sigaction(SIGTERM, &sa, NULL) == -1) {
        printf("sigaction failed\n");
        return EXIT_FAILURE;
    }

    unsigned int counter = 0;

    MIGRATE_LOCAL(counter);

    if (!kitsune_is_updating()) {
        synchronized_data = malloc(sizeof(*synchronized_data) * N_DATA_ELEMENTS);
        if (!synchronized_data) {
            printf("malloc failed\n");
            return EXIT_FAILURE;
        }

        initialize_synchronized_data(synchronized_data);

        fprintf(stderr, "%u, %zu\n",
                N_DATA_ELEMENTS, N_DATA_ELEMENTS * sizeof(data_t));
    } else {
        fprintf(stderr, "%u, %zu\n",
                N_DATA_ELEMENTS, N_DATA_ELEMENTS * sizeof(data_t));

        kitsune_do_automigrate();
    }

    while (1) {
        kitsune_update("main");
        counter++;

        sleep(sleeptime);

        if (DO_EXIT) {
            break;
        }
    }

    return 0;
}
