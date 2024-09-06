{ lib
, stdenv
, fetchFromGitHub
, kernel
}:

let
  version = "ed375bb8d53f57d3da84e575ae04a9e8532b2511";
  sha256 = "sha256-2sgZo+1sIhC0dUAdBKCU3shh0U4I5rseevpVpQg5LgY=";
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
