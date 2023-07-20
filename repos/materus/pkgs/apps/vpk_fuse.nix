{ pkgs, lib, stdenv, fetchFromGitHub, fuse, pkg-config }:


stdenv.mkDerivation rec {
  pname = "vpk_fuse";
  version = "15042023";
  src = fetchFromGitHub {
    owner = "ElementW";
    repo = "vpk_fuse";
    rev = "4e7e4b78d73f9e09287079d3e62f53cbc5d04a37";
    sha256 = "sha256-HoENTIHM4Nmocoh2bxxuk1ZLsq4bSUGzeKgEufsPUJA=";
  };


  buildInputs = [ fuse pkg-config];

  installPhase = ''
  mkdir -p $out/bin
  install -m 755 -D vpk_fuse $out/bin/vpk_fuse
  '';

  meta = with lib; {
    description = "A FUSE filesystem which can open Valve PacKage files (VPK).";
    homepage = "https://github.com/ElementW/vpk_fuse";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
