{ lib
, fetchFromGitHub
, stdenv
, cmake
, pkg-config
, nasm
, ...
}:
let
  rev = "misrc_extract-0.3";
in
stdenv.mkDerivation {
  name = "misrc_extract";

  src = fetchFromGitHub {
    inherit rev;
    owner = "Stefan-Olt";
    repo = "MISRC";
    sha256 = "sha256-7uhuA492QNcG86eZ0hxTHgdcoUIiSM5AADNa+q5wnEQ=";
  };

  dontWrapQtApps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    nasm
  ];

  preConfigure = ''
    cd misrc_extract
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  meta = with lib; {
    description = "Tool to extract the two ADC channels and the AUX data from the raw capture.";
    license = licenses.gpl3;
    maintainers = [ "JuniorIsAJitterbug" ];
    homepage = "https://github.com/Stefan-Olt/MISRC";
  };
}
