#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <inttypes.h>

#include <kitsune.h>

static const unsigned int sleeptime E_MANUAL_MIGRATE = 5;

#define DATA_SIZE (20971520)

data_t *E_PTRARRAY(DATA_SIZE) synchronized_data;

void initialize_synchronized_data(data_t *data)
{
    for (uint32_t i = 0; i < DATA_SIZE; i++) {
        data[i] = (data_t){ .a = (uint32_t)rand(), .b = (uint32_t)rand() };
    }
}

uint64_t calculate_data_checksum(const data_t *data)
{
    uint64_t sum = 0;
    for (uint32_t i = 0; i < DATA_SIZE; i++) {
        sum += (data[i].a + data[i].b);
    }
    return sum;
}

int main(void) E_NOTELOCALS
{
    unsigned int counter = 0;

    MIGRATE_LOCAL(counter);

    if (!kitsune_is_updating()) {
        printf("Initializing\n");

        synchronized_data = malloc(sizeof(*synchronized_data) * DATA_SIZE);
        if (!synchronized_data) {
            printf("malloc failed\n");
            return EXIT_FAILURE;
        }

        initialize_synchronized_data(synchronized_data);
        printf("Initialized\n");
    } else {
        printf("Updating\n");

        kitsune_do_automigrate();
    }

    int calculated_checksum = 0;

    while (1) {
        kitsune_update("main");

        if (!calculated_checksum) {
            printf("Calculating checksum\n");
            uint64_t checksum = calculate_data_checksum(synchronized_data);
            printf("Data checksum: %" PRIu64 "\n", checksum);

            calculated_checksum = 1;
        }

        printf("%u\n", counter);
        counter++;

        sleep(sleeptime);
    }

    return 0;
}


