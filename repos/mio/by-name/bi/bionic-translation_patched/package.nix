{
  bionic-translation,
  lib,
  stdenv,
  ...
}:

bionic-translation.overrideAttrs (old: {
  pname = "bionic-translation-patched";

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-DO_LARGEFILE=0 -DSIGRTMIN=32 -DSIGRTMAX=64 -Dsa_restorer=sa_mask";

  postPatch =
    (old.postPatch or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # Darwin host ART links -ldl_bio; provide thin POSIX dl* wrappers so
      # bionic_dlopen/dlsym/dlerror resolve (real ELF linker is Linux-only).
      cat << 'EOF' > dl_bio_stub.c
      #include <dlfcn.h>
      void *bionic_dlopen(const char *filename, int flag) {
        return dlopen(filename, flag);
      }
      const char *bionic_dlerror(void) { return dlerror(); }
      void *bionic_dlsym(void *handle, const char *symbol) {
        return dlsym(handle, symbol);
      }
      int bionic_dlclose(void *handle) { return dlclose(handle); }
      int bionic_dladdr(const void *addr, Dl_info *info) {
        return dladdr(addr, info);
      }
      EOF
      touch dummy.c
      cat << 'EOF' > meson.build
      project('bionic_translation', 'c')
      shared_library('c_bio', 'dummy.c', install: true)
      shared_library('m_bio', 'dummy.c', install: true)
      shared_library('pthread_bio', 'dummy.c', install: true)
      shared_library('dl_bio', 'dl_bio_stub.c', install: true)
      shared_library('stdc++_bio', 'dummy.c', install: true)
      EOF
    '';

  buildInputs = builtins.filter (
    drv: !(stdenv.hostPlatform.isDarwin && lib.getName drv == "wayland")
  ) (old.buildInputs or [ ]);
})
