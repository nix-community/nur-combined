{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "vdt";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "dpiparo";
    repo = "vdt";
    rev = "v${version}";
    hash = "sha256-dGhlLhDBw3iI8wAoXVS1Ynq8U3CExGWF/+XhMpG5OC4=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A collection of fast and inline implementations of mathematical functions";
    homepage = "https://github.com/dpiparo/vdt";
    license = licenses.gpl3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
