#include <errno.h>
#include <stdio.h>

FILE *popen(const char *c, const char *m) {
  (void)c;
  (void)m;
  errno = ENOSYS;
  return NULL;
}

int pclose(FILE *f) {
  (void)f;
  return -1;
}

int system(const char *c) {
  (void)c;
  errno = ENOSYS;
  return -1;
}
