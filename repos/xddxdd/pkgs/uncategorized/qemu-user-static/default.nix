{
  dpkg,
  fetchurl,
  lib,
  stdenv,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);

  mkPackage =
    source:
    stdenv.mkDerivation {
      pname = "qemu-user-static";
      inherit (source) version src;

      nativeBuildInputs = [ dpkg ];

      unpackPhase = ''
        runHook preUnpack

        dpkg -x $src .

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

      passthru.updateScript = [ (toString ./update.sh) ];

      meta = {
        mainProgram = "qemu-amd64-static";
        maintainers = with lib.maintainers; [ xddxdd ];
        homepage = "http://www.qemu.org/";
        description = "Generic and open source machine emulator, virtualizer";
        license = lib.licenses.gpl2Plus;
      };
    };
in
if stdenv.hostPlatform.isx86_64 then
  mkPackage {
    inherit (sources.qemu-user-static-amd64) version;
    src = fetchurl {
      inherit (sources.qemu-user-static-amd64) url hash;
    };
  }
else if stdenv.hostPlatform.isi686 then
  mkPackage {
    inherit (sources.qemu-user-static-i386) version;
    src = fetchurl {
      inherit (sources.qemu-user-static-i386) url hash;
    };
  }
else if stdenv.hostPlatform.isAarch32 then
  mkPackage {
    inherit (sources.qemu-user-static-armhf) version;
    src = fetchurl {
      inherit (sources.qemu-user-static-armhf) url hash;
    };
  }
else if stdenv.hostPlatform.isAarch64 then
  mkPackage {
    inherit (sources.qemu-user-static-arm64) version;
    src = fetchurl {
      inherit (sources.qemu-user-static-arm64) url hash;
    };
  }
else
  throw "Unsupported architecture"
