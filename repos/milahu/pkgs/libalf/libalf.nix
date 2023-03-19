{ lib
, pkgs
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "libalf";
  version = "0.3-unstable-2020-05-12";

  # https://github.com/libalf/libalf
  srcAll = fetchFromGitHub {
    owner = "libalf";
    repo = "libalf";
    rev = "37f449dde38faea4ff03b5fe777dc906e7341661";
    sha256 = "sha256-YvypC3HNE50wnmtu7Dvdz7Pb0xwnQh0i4Jzl4e1SYWc="; # todo
  };

  src = srcAll + "/libalf";

  makeFlags = [
    "PREFIX=$(out)"
  ];

  libamore = stdenv.mkDerivation {
    pname = "libamore";
    inherit version makeFlags;
    src = srcAll + "/libAMoRE";
  };

  buildInputs = [
    libamore
  ];

  meta = with lib; {
    description = "Automata Learning Factory";
    homepage = "https://github.com/libalf/libalf";
    #license = licenses.lgpl; # FIXME error: attribute 'lgpl' missing
    #platforms = platforms.linux;
  };
}
