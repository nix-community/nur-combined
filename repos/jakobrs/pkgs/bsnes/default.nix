{ lib, stdenv, fetchFromGitHub
, pkg-config
, openal, libpulseaudio, libao, SDL2, libudev, libXv, alsaLib, libXrandr
, hiroPlatform ? "qt5" # One of "gtk3" and "qt5"
, gtk3
, qtbase, wrapQtAppsHook }:

let
  useGtk = hiroPlatform == "gtk3";
  useQt = hiroPlatform == "qt5";

in stdenv.mkDerivation rec {
  pname = "bsnes";
  version = "unstable-2021-03-13";

  src = fetchFromGitHub {
    owner = "bsnes-emu";
    repo = "bsnes";
    rev = "f57657f27ddec337b1960c7ddaa1b23894bc00c3";
    hash = "sha256:1gmgw0v1nd0chy7jwl17mq12jy100hip1hnwgqfbwqs0f0p0v42y";
  };

  postUnpack = ''
    chmod +w source -R
  '';

  sourceRoot = "source/bsnes";

  makeFlags = [
    "hiro=${hiroPlatform}"
    "out=bsnes"
    "prefix=${placeholder "out"}"
  ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkg-config ] ++ lib.optional useQt wrapQtAppsHook;

  buildInputs = [
    openal libpulseaudio libao SDL2 libudev libXv alsaLib libXrandr
  ] ++ lib.optional useGtk gtk3
    ++ lib.optional useQt qtbase;
}
