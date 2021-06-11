{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let debExtract = stdenv.mkDerivation {
  name = "beam-wallet";
  src = fetchurl {
    url = "https://builds.beam.mw/mainnet/2019.02.11/Release/linux/Beam-Wallet-1.2.4419.deb";
    sha256 = "19ws0zc6gkvmhyzjf731mwv2nm80zr924l9pna48zs2dj2ir89nk";
  };
  phases = [ "buildPhase" ];
  buildInputs = [ dpkg ];
  buildPhase = ''
    mkdir $out
    dpkg-deb -x $src $out
    mv $out/usr/* $out
    rmdir $out/usr
  '';
};
in buildFHSUserEnv {
  name = "BeamWallet";
  targetPkgs = pkgs: with pkgs; [
    xorg.libX11
    xorg.libxcb
    libGL
    freetype
    fontconfig
    xorg.libXi
    xorg.libXrender
    cups
    stdenv.cc.cc.lib
    debExtract
  ];
  runScript = "/usr/bin/BeamWallet";

  meta = {
    description = "Beam Mimblewimble Wallet";
    homepage = https://www.beam.mw/;
    license = lib.licenses.asl20;
    broken = true;
  };
}
