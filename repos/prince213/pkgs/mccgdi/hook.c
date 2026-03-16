#include <dlfcn.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void* (*dlopen_)(const char*, int);
FILE* (*fopen_)(const char*, const char*);

#define LIBDIR "/usr/lib/"
#define LIBDIR_REAL "@libdir@/"

void* dlopen(const char* file, int mode) {
  if (dlopen_ == NULL) dlopen_ = dlsym(RTLD_NEXT, "dlopen");

  if (strncmp(file, LIBDIR, strlen(LIBDIR)) == 0) {
    char* buf = malloc(strlen(LIBDIR_REAL) + strlen(file) - strlen(LIBDIR) + 1);
    if (buf == NULL) return NULL;
    strcpy(buf, LIBDIR_REAL);

    file += strlen(LIBDIR);
    if (strcmp(file, "libcups.so") == 0)
      buf = "@cups@/lib/libcups.so";
    else if (strcmp(file, "libgs.so") == 0)
      buf = "@ghostscript@/lib/libgs.so";
    else
      strcat(buf, file);

    file = buf;
  };

  return dlopen_(file, mode);
}

#define DATADIR "/usr/local/share/"
#define DATADIR_REAL "@datadir@/"

FILE* fopen(const char* pathname, const char* mode) {
  if (fopen_ == NULL) fopen_ = dlsym(RTLD_NEXT, "fopen");

  if (strncmp(pathname, DATADIR, strlen(DATADIR)) == 0) {
    char* buf =
        malloc(strlen(DATADIR_REAL) + strlen(pathname) - strlen(DATADIR) + 1);
    if (buf == NULL) return NULL;
    strcpy(buf, DATADIR_REAL);
    strcat(buf, pathname + strlen(DATADIR));
    pathname = buf;
  };

  return fopen_(pathname, mode);
}
