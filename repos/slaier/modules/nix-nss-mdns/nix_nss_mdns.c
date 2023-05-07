#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>

static int mdns_flag = 0;

int __nss_configure_lookup(void *restrict handle, const char *restrict symbol) {
    int (*f)() = dlsym(RTLD_NEXT, "__nss_configure_lookup");
    if (!f) {
        fprintf(stderr, "__nss_configure_lookup does not exist.\n");
        return -1;
    }
    if (!strcmp(handle, "hosts")) {
        if (!mdns_flag) {
            if (!dlopen("@nssmdns@/lib/libnss_mdns4_minimal.so.2", RTLD_NOW))
                fprintf(stderr, "unable to load nss_mdns4_minimal backend\n");
            if (!dlopen("@nssmdns@/lib/libnss_mdns4.so.2", RTLD_NOW))
                fprintf(stderr, "unable to load nss_mdns4 backend\n");
            mdns_flag = 1;
        }
        return f("hosts", "mdns4_minimal [NOTFOUND=return] files dns mdns4");
    }
    return f(handle, symbol);
}
