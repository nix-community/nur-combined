{ stdenv, lib, pkgs, fetchurl,fetchFromGitHub, upx, wine }:
stdenv.mkDerivation rec {
  pname = "pfsshell";
  version = "64f8c2";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "makefu";
    repo = "pfsshell";
    rev = version;
    sha256 = "01lbqf8s91p8id58xa16fp555i03vfycqvhv7qzpnrjy6yvp9dm8";
  };

  buildInputs = [ ];

  makeFlags = [ ];

  installPhase = ''
    mkdir -p $out/bin
    cp pfsshell $out/bin
  '';

  meta = {
    homepage = https://github.com/uyjulian/pfsshell ;
    description = "browse and transfer files to/from PFS filesystems";
  };
}
