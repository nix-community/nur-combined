{pkgs}:
# Bootstrap a new stdenv that includes our nss_sss in glibc
let
  glibc = pkgs.glibc.overrideDerivation (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        sed -i -e 's@_PATH_VARDB.*@_PATH_VARDB "/var/lib/misc"@' sysdeps/unix/sysv/linux/paths.h
        sed -i -e 's@_PATH_VARDB.*@_PATH_VARDB "/var/lib/misc"@' sysdeps/generic/paths.h
      '';
    postInstall =
      old.postInstall
      + ''
        ln -s ${pkgs.nss_sss}/lib/*.so.* $out/lib
      '';
  });
  binutils = pkgs.binutils.override {
    libc = glibc;
  };
  gcc = pkgs.gcc.override {
    bintools = binutils;
    libc = glibc;
  };

  thisStdenv = pkgs.stdenv.override {
    cc = gcc;
    overrides = self: super: {
      inherit glibc binutils gcc;
      inherit (pkgs) fetchurl;
    };
    allowedRequisites =
      pkgs.stdenv.allowedRequisites
      ++ [glibc.out glibc.dev glibc.bin binutils pkgs.nss_sss];
  };
in
  thisStdenv
# (prevStage: {
#   inherit config overlays;
#   stdenv = import ./generic {
#   }
# })
# (vanillaPackages: {
# config.replaceStdenv vanillaPackages -> stdenv
# })

