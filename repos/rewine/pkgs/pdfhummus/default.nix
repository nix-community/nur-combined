{ lib
, stdenv
, fetchFromGitHub
, cmake
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "pdfhummus";
  version = "4.5.6";

  src = fetchFromGitHub {
    owner = "galkahana";
    repo = "PDF-Writer";
    rev = "v${version}";
    hash = "sha256-F195hyUia6o+7PKPqNANf/Ixr8OYpj1HMaB0dqxyMBI=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  meta = with lib; {
    description = "A Fast and Free C++ Library for Creating, Parsing an Manipulating PDF Files and Streams";
    homepage = "www.pdfhummus.com";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

