{ stdenv, lib, pkgs, fetchurl,fetchFromGitHub, upx, wine }:
stdenv.mkDerivation rec {
  pname = "hdl-dump";
  version = "75df8d7";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "AKuHAK";
    repo = "hdl-dump";
    rev = version;
    sha256 = "10jjr6p5yn0c182x17m7q68jmf8gizcny7wjxw7z5yh0fv5s48z4";
  };

  buildInputs = [ upx wine ];

  makeFlags = [ "RELEASE=yes" ];

  # uses wine, currently broken
  #postBuild = ''
  #  make -C gui
  #'';

  installPhase = ''
    mkdir -p $out/bin
    cp hdl_dump $out/bin
  '';

  meta = {
    homepage = https://github.com/AKuHAK/hdl-dump ;
    description = "copy isos to psx hdd";
    license = lib.licenses.gpl2;
  };
}
