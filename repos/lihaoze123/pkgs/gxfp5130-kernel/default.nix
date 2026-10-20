{ lib
, stdenv
, fetchFromGitHub
, kernel ? linuxPackages.kernel
, linuxPackages
,
}:
let pin = lib.importJSON ../gxfp5130-libfprint/source.json;
in
stdenv.mkDerivation {
  pname = "gxfp-linux-driver";
  version = "unstable";

  src = fetchFromGitHub { inherit (pin) owner repo rev hash; };
  sourceRoot = "source/kernel";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
    install -m644 gxfp.ko $out/lib/modules/${kernel.modDirVersion}/extra/gxfp.ko

    runHook postInstall
  '';

  dontStrip = true;

  passthru = {
    inherit (kernel) modDirVersion;
  };

  meta = {
    description = "Kernel module for the GXFP5130 fingerprint sensor over eSPI";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
