{
  stdenv,
  lib,
  pkgs,
  fetchgit,
  pkg-config,
  ...
}:

stdenv.mkDerivation {
  pname = "rkflashtool-fork";
  version = "unstable-2025-01-04";

  src = fetchgit {
    url = "https://github.com/linux-rockchip/rkflashtool";
    rev = "6022dd724e8247ff7a0825b0eda6a07c446aacdd";
    sha256 = "sha256-e3vY9K6JHVR/X/lmmJw1gQAH8DqYCiLpfXEwoEWOn2g=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ pkgs.libusb1 ];

  installPhase = ''
    mkdir -p $out/bin
    cp rkunpack rkcrc rkflashtool rkparameters rkparametersblock rkunsign rkmisc $out/bin
  '';

  meta = {
    license = lib.licenses.bsd2;
    homepage = "https://github.com/linux-rockchip/rkflashtool";
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    description = "Tools for flashing Rockchip devices";
    maintainers = with lib.maintainers; [ "dmfrpro" ];
    platforms = lib.platforms.linux;
    mainProgram = "rkflashtool";
  };
}
