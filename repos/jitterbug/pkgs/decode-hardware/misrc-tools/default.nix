{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  pkg-config,
  ninja,
  nasm,
  hsdaoh,
  ffmpeg,
  flac,
  maintainers,
  ...
}:

let
  pname = "misrc-tools";
  version = "0.5.1";

  rev = "misrc_tools-${version}";
  hash = "sha256-gn7UfCW76Nex+fxTzQOQl6G22WifPF6v7YEXCTqK23Q=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "Stefan-Olt";
    repo = "MISRC";

    sparseCheckout = [
      "misrc_tools"
    ];
  };

  sourceRoot = "source/misrc_tools";

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
  ];

  buildInputs = [
    nasm
    hsdaoh
    ffmpeg
    flac
  ];

  meta = {
    inherit maintainers;
    description = "Tools for the MISRC project.";
    homepage = "https://github.com/Stefan-Olt/MISRC";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
