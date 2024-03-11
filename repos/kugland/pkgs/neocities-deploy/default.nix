{
  pkgs,
  lib,
  fetchFromGitHub,
  rustPlatform,
  buildRustPackage ? rustPlatform.buildRustPackage,
}:
buildRustPackage rec {
  pname = "neocities-deploy";
  version = "0.1.11";
  src = fetchFromGitHub {
    owner = "kugland";
    repo = "neocities-deploy";
    rev = "v${version}";
    hash = "sha256-Xy+YfXSb2ffIu4Ost5tKDXXAOzR+kkfR5kwqdlVLo0o=";
  };
  cargoSha256 = "sha256-xDuQQjAt14V6gNqu/YG3j1VvWFKLDPBaw2yGhqDRXD8=";
  meta = with lib; {
    description = "A command-line tool for deploying your Neocities site";
    homepage = "https://github.com/kugland/neocities-deploy";
    license = licenses.gpl3;
    maintainers = [];
  };
}
