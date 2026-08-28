#include <dlfcn.h>

void *bionic_dlopen(const char *filename, int flag) {
  return dlopen(filename, flag);
}

const char *bionic_dlerror(void) {
  return dlerror();
}

void *bionic_dlsym(void *handle, const char *symbol) {
  return dlsym(handle, symbol);
}

int bionic_dlclose(void *handle) {
  return dlclose(handle);
}

int bionic_dladdr(const void *addr, Dl_info *info) {
  return dladdr(addr, info);
}
