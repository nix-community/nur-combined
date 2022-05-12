{ stdenv, fetchFromGitHub, pkgs, ... }:

stdenv.mkDerivation rec {
  pname = "bzip3";
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "kspalaiologos";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-vIH+01MDrpWXHpyaYjM2GirUHx4uyFLqkCvQJFsB+aw=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  doCheck = true;

  preInstall = ''
    mkdir -p $out/{bin,lib,include}
  '';
}
