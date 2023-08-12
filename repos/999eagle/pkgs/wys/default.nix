{
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  cmake,
  libpulseaudio,
  glib,
  modemmanager,
}:
stdenv.mkDerivation rec {
  pname = "wys";
  version = "0.1.11";

  src = fetchFromGitLab {
    domain = "source.puri.sm";
    owner = "Librem5";
    repo = "wys";
    rev = "v${version}";
    hash = "sha256-vZYDZE6ojioQEJcootcGfxukF/HnD3JaKt6eNASmOH8=";
  };

  nativeBuildInputs = [meson ninja cmake pkg-config];
  buildInputs = [libpulseaudio glib modemmanager];
}
