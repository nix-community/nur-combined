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
      cat << 'EOF' > meson.build
      project('bionic_translation', 'c')
      shared_library('c_bio', 'dummy.c', install: true)
      shared_library('m_bio', 'dummy.c', install: true)
      shared_library('pthread_bio', 'dummy.c', install: true)
      shared_library('dl_bio', 'dummy.c', install: true)
      shared_library('stdc++_bio', 'dummy.c', install: true)
      EOF
      touch dummy.c
    '';

  buildInputs = builtins.filter (
    drv: !(stdenv.hostPlatform.isDarwin && lib.getName drv == "wayland")
  ) (old.buildInputs or [ ]);
})
