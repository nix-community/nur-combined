#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#ifndef SYSTEMD_COREDUMP
#error "SYSTEMD_COREDUMP must name the systemd-coredump executable"
#endif

enum {
    SIGNAL_ARGUMENT = 1,
    EXECUTABLE_ARGUMENT = 2,
    EXPECTED_ARGUMENT_COUNT = 12,
};

static int has_suffix(const char *string, const char *suffix)
{
    const size_t string_length = strlen(string);
    const size_t suffix_length = strlen(suffix);

    return string_length >= suffix_length
        && memcmp(string + string_length - suffix_length, suffix, suffix_length) == 0;
}

int main(int argc, char **argv)
{
    if (argc != EXPECTED_ARGUMENT_COUNT) {
        dprintf(STDERR_FILENO,
                "wine-coredump-filter: expected %d arguments, received %d\n",
                EXPECTED_ARGUMENT_COUNT - 1, argc - 1);
        return 64;
    }

    /* %E escapes path separators as '!'. Do not suppress any other signal. */
    if (strcmp(argv[SIGNAL_ARGUMENT], "3") == 0
        && has_suffix(argv[EXECUTABLE_ARGUMENT], "!wine-preloader"))
        return 0;

    /* Reuse argv storage to give systemd-coredump its expected argv[0]. */
    argv[EXECUTABLE_ARGUMENT] = SYSTEMD_COREDUMP;
    execv(SYSTEMD_COREDUMP, &argv[EXECUTABLE_ARGUMENT]);

    dprintf(STDERR_FILENO, "wine-coredump-filter: execv(%s): %s\n",
            SYSTEMD_COREDUMP, strerror(errno));
    return 127;
}
