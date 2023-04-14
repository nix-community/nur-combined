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
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = pname;
    rev = "v${version}";
    sha256 = "1c55vbar97n17hzl9gla43bd26n4yc7vrf87ly0b2fwpwr8i8iax";
  };

  nativeBuildInputs = [meson pkg-config cmake ninja wayland-scanner];
  buildInputs = [wayland-protocols wayland pulseaudio];

  meta = with lib; {
    description = "Prevents swayidle from sleeping while any application is outputting or receiving audio";
    homepage = "https://github.com/ErikReider/SwayAudioIdleInhibit";
    license = licenses.gpl3Only;
  };
}
