{
  fetchFromGitHub,
  lib,
  meson,
  ninja,
  pkg-config,
  stdenv,
  sudo,
  ...
}:
let
  pname = "overlayfs-tools";
  version = "unstable";
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "kmxz";
    repo = pname;
    rev = "7a4a0c4f2c6c86aa46a40e3468e394fd4a237491";
    hash = "sha256-3LgUmlIymWNAWWo6/4TRMRP5jOeAYc/BQRTJ8rk8be0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    sudo
  ];

  meta = with lib; {
    description = "Maintenance tools for overlay-filesystem";
    homepage = "https://github.com/kmxz/overlayfs-tools/tree/master";
    license = licenses.wtfpl;
  };
}
