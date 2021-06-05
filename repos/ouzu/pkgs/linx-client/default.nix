{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

stdenv.mkDerivation buildGoPackage rec {
  pname = "linx-client";
  version = "1.5.2";

  goPackagePath = "github.com/andreimarcu/linx-client";

  src = fetchFromGitHub {
    owner = "andreimarcu";
    repo = "linx-client";
    rev = "v${version}";
    sha256 = "1ni6q44fgz06sjpz2vf1b532qsb1af2cysphwpzy2269yxwcki3v";
  };

  goDeps = ./deps.nix; 

  buildFlags = [ "--tags" "release" ];

  meta = with lib; {
    description = "Simple client for linx-server";
    homepage = "https://github.com/andreimarcu/linx-client";
    license = licenses.gpl3;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
