{ pkgs
, lib
, fetchFromGitHub
, fenix
,
}:

let
  toolchain = fenix.minimal.toolchain;
  buildRustPackage = (pkgs.makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  }).buildRustPackage;

in
  buildRustPackage rec {
  pname = "neocities-deploy";
  version = "0.1.13";
  src = fetchFromGitHub {
    owner = "kugland";
    repo = "neocities-deploy";
    rev = "v${version}";
    hash = "sha256-Ax1xmNyt+Gymk28p9lXh+CV17rWjMBKIZtc+nthic+8=";
  };
  cargoHash = "sha256-wdO46fRqzrWZNSoNAA5FHBckUxLtsxmc72UVtmGhJYU=";
  doCheck = false;
  meta = with lib; {
    description = "A command-line tool for deploying your Neocities site";
    homepage = "https://github.com/kugland/neocities-deploy";
    license = licenses.gpl3;
    maintainers = [ lib.maintainers.kugland ];
  };
}
