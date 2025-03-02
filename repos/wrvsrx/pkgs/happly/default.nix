{
  stdenv,
  meson,
  ninja,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  patches = [ ./pc.patch ];
  nativeBuildInputs = [
    meson
    ninja
  ];
}
