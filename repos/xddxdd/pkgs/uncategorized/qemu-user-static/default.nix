{
  sources,
  stdenv,
  lib,
  ...
}:
let
  mkPackage =
    source:
    stdenv.mkDerivation {
      pname = "qemu-user-static";
      inherit (source) version src;

      unpackPhase = ''
        runHook preUnpack

        ar x $src
        tar xf data.tar.xz

        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r usr/bin $out/bin

        for F in $out/bin/*; do
          ln -sf ''${F} ''${F}-static
        done

        runHook postInstall
      '';

      dontFixup = true;

      meta = with lib; {
        mainProgram = "qemu-amd64-static";
        maintainers = with lib.maintainers; [ xddxdd ];
        homepage = "http://www.qemu.org/";
        description = "A generic and open source machine emulator and virtualizer";
        license = licenses.gpl2Plus;
      };
    };
in
if stdenv.isx86_64 then
  mkPackage sources.qemu-user-static-amd64
else if stdenv.isi686 then
  mkPackage sources.qemu-user-static-i386
else if stdenv.isAarch64 then
  mkPackage sources.qemu-user-static-arm64
else if stdenv.isAarch32 then
  mkPackage sources.qemu-user-static-armhf
else
  throw "Unsupported architecture"
