{
  stdenv,
  meson,
  ninja,
  pkg-config,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  postUnpack = "cp ${./meson.build} source/meson.build";
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];
}
