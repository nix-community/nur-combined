#include <stdio.h>
#include <stdlib.h>
#include <pwd.h>
#include <unistd.h>

int main(void) {
    struct passwd *pw = getpwuid(getuid());

    if (!pw) {
        perror("getpwuid");
        return EXIT_FAILURE;
    }

    printf("%s\n", pw->pw_dir);

    return EXIT_SUCCESS;
}
