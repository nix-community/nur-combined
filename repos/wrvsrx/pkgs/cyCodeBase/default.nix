{
  stdenv,
  meson,
  ninja,
  pkg-config,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "cyCodeBase";
  version = "0-unstable-2024-05-26";

  src = fetchFromGitHub {
    owner = "cemyuksel";
    repo = "cyCodeBase";
    rev = "6d3a2c9958d71794016119826d39206903e00d26";
    hash = "sha256-+lrqIVr16I/+FJraJ8Js/TuPMYaHKb3e6+IUG2CNzas=";
  };
  postUnpack = "cp ${./meson.build} source/meson.build";
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];
}
