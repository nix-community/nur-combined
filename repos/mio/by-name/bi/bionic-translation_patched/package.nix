{
  bionic-translation,
  lib,
  stdenv,
  ...
}:

let
  inherit (lib) filter getName optionalString;

  darwinPostPatch = ''
    cp ${./dl_bio_stub.c} dl_bio_stub.c
    touch dummy.c
    cp ${./meson-darwin.build} meson.build
  '';

in
bionic-translation.overrideAttrs (old: {
  pname = "bionic-translation-patched";

  env.NIX_CFLAGS_COMPILE = optionalString stdenv.hostPlatform.isDarwin "-DO_LARGEFILE=0 -DSIGRTMIN=32 -DSIGRTMAX=64 -Dsa_restorer=sa_mask";

  postPatch = (old.postPatch or "") + optionalString stdenv.hostPlatform.isDarwin darwinPostPatch;

  buildInputs = filter (drv: !(stdenv.hostPlatform.isDarwin && getName drv == "wayland")) (
    old.buildInputs or [ ]
  );
})
