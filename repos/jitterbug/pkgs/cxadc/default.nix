{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  ...
}:

let
  pname = "cxadc";
  version = "0-unstable-2026-01-15";

  rev = "c6f3b23e431cdda2e939d73008e643b54bda56b7";
  hash = "sha256-6icpVYvRM+N7DG68wDCPxZ57bDLIp03bn1CEUIUlHa4=";
in
stdenv.mkDerivation {
  inherit pname version;
  passthru.moduleName = pname;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "happycube";
    repo = "cxadc-linux3";
  };

  hardeningDisable = [
    "pic"
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildFlags = [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    install -D cxadc.ko $out/lib/modules/${kernel.modDirVersion}/misc/cxadc.ko
    install -m755 -D leveladj $out/bin/leveladj
    install -m755 -D levelmon $out/bin/levelmon
  '';

  meta = {
    inherit maintainers;
    homepage = "https://github.com/happycube/cxadc-linux3";
    description = "cxadc is an alternative Linux driver for the Conexant CX2388x series of video decoder/encoder chips used on many PCI TV tuner and capture cards.";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
