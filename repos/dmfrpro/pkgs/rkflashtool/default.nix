{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "rkflashtool";
  version = "unstable-2025-09-30";

  src = pkgs.fetchgit {
    url = "https://github.com/linux-rockchip/rkflashtool";
    rev = "fc2181c577ef3fb1e821818dfd07e0dac0575b74";
    sha256 = "sha256-uXjMK07dIa/LUbaokLViJXQHkthGjpdXQLQEYN2v6VE=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = [ pkgs.libusb1 ];

  installPhase = ''
    mkdir -p $out/bin
    cp rkunpack rkcrc rkflashtool rkparameters \
      rkparametersblock rkunsign rkmisc $out/bin
  '';

  meta = {
    license = pkgs.lib.licenses.bsd2;
    homepage = "https://github.com/linux-rockchip/rkflashtool";
    sourceProvenance = [ pkgs.lib.sourceTypes.fromSource ];
    description = "Tools for flashing Rockchip devices";
    maintainers = [ "dmfrpro" ];
    platforms = pkgs.lib.platforms.linux;
    mainProgram = "rkflashtool";
  };
}
