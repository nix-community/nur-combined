#include "my_application.h"
#include <dlfcn.h>

int main(int argc, char** argv) {
  dlopen("libhub.so", RTLD_NOW | RTLD_GLOBAL);
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}

