{ lib, stdenv, fetchFromGitHub, autoreconfHook, bison, flex }:

stdenv.mkDerivation rec {
  pname = "hfst";
  version = "3.15.4";

  src = fetchFromGitHub {
    owner = "hfst";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-YOh9atPk3u16xtl2bBPY+4159/AFdnptqnngCHnWa24=";
  };

  nativeBuildInputs = [ autoreconfHook bison flex ];

  meta = with lib; {
    description = "Helsinki Finite-State Technology (library and application suite)";
    homepage = "https://hfst.github.io";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
