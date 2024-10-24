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
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6bdIkNosp/mzH5SiyK6Mox/z8kuFk5RLMmcFZ2VIi0g=";
  };

  nativeBuildInputs = [meson pkg-config cmake ninja wayland-scanner];
  buildInputs = [wayland-protocols wayland pulseaudio];

  meta = with lib; {
    description = "Prevents swayidle from sleeping while any application is outputting or receiving audio";
    homepage = "https://github.com/ErikReider/SwayAudioIdleInhibit";
    license = licenses.gpl3Only;
  };
}
