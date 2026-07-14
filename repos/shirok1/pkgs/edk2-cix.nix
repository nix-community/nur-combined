{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "edk2-cix";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/radxa-pkg/edk2-cix/releases/download/${finalAttrs.version}/edk2-cix_${finalAttrs.version}_all.deb";
    hash = "sha256-T5B7DhxXvrbKX67TI3RVjjV5fvjxz2mkqqMu8aXfsqE=";
  };

  nativeBuildInputs = [ dpkg ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r usr/share/edk2 "$out/edk2"
    runHook postInstall
  '';

  meta = {
    description = "Prebuilt CIX EDK II (UEFI) firmware images for Radxa Orion O6/O6N and generic CIX P1 boards";
    homepage = "https://github.com/radxa-pkg/edk2-cix";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = [ lib.sourceTypes.binaryFirmware ];
    platforms = [ "aarch64-linux" ];
  };
})
