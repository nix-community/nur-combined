{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  pkg-config,
  cmake,
  ninja,
  wayland,
  wayland-scanner,
  wayland-protocols,
  pulseaudio,
}:
stdenv.mkDerivation rec {
  pname = "swayaudioidleinhibit";
  version = "unstable-2023-08-09";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = pname;
    rev = "c850bc4812216d03e05083c69aa05326a7fab9c7";
    hash = "sha256-MKzyF5xY0uJ/UWewr8VFrK0y7ekvcWpMv/u9CHG14gs=";
  };

  nativeBuildInputs = [meson pkg-config cmake ninja wayland-scanner];
  buildInputs = [wayland-protocols wayland pulseaudio];

  meta = with lib; {
    description = "Prevents swayidle from sleeping while any application is outputting or receiving audio";
    homepage = "https://github.com/ErikReider/SwayAudioIdleInhibit";
    license = licenses.gpl3Only;
  };
}
