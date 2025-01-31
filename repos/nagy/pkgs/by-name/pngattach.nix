{
  lib,
  stdenv,
  fetchFromGitHub,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "pngattach";
  version = "unstable-2022-10-12";

  src = fetchFromGitHub {
    owner = "skeeto";
    repo = "scratch";
    rev = "4cf540007314240928b79441febf9a6d9dae2ca7";
    hash = "sha256-AZuUdq/qLeui/GmZxbuTpUH/f+BfP1dXLU3TtTTTJQA=";
  };

  sourceRoot = "source/${pname}";

  buildInputs = [ zlib ];

  makeFlags = [
    "PREFIX=$(out)"
    "CC:=$(CC)"
  ];

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "Attach files to a PNG image as metadata";
    license = licenses.unlicense;
  };
}
