{ lib
, stdenv
, fetchFromGitHub
, kernel
}:

let
  version = "6ffc17cfb504b8d71da6fa84891e706558af3d40";
  sha256 = "sha256-9k5uiRdhTdZs+SqluvefJL9z+9t+KjpPyZQTcv0ko3E=";
in
stdenv.mkDerivation {
  name = "cxadc";
  passthru.moduleName = "cxadc";

  src = fetchFromGitHub {
    owner = "happycube";
    repo = "cxadc-linux3";
    rev = version;
    inherit sha256;
  };

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  buildFlags = [ "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  installPhase = ''
    install -D cxadc.ko $out/lib/modules/${kernel.modDirVersion}/misc/cxadc.ko
    mkdir -p $out/bin
    install -m 755 leveladj $out/bin/leveladj
  '';

  meta = with lib; {
    homepage = "https://github.com/happycube/cxadc-linux3";
    description = "cxadc is an alternative Linux driver for the Conexant CX2388x series of video decoder/encoder chips used on many PCI TV tuner and capture cards.";
    maintainers = [ "JuniorIsAJitterbug" ];
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
