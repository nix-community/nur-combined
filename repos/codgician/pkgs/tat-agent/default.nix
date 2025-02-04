{
  lib,
  pkgs,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "tat-agent";
  version = "0.1.28-unstable-2024-10-21";

  src = fetchFromGitHub {
    owner = "Tencent";
    repo = pname;
    rev = "c2e6983c676b2e46b3f52f059c48abb39ec267c8";
    hash = "sha256-o4UG3cvRx5Ajt0U/6PR33TDjX9a7niCue46ESeOuINY=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-H6nKnc4ZvrnewVIEFueha8KFRZvX660NaRkEhXi83BQ=";

  nativeBuildInputs = with pkgs; [ perl ];
  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=main"
    ];
  };

  meta = {
    description = "TAT agent is an agent written in Rust, which run in CVM, Lighthouse or CPM 2.0 instances.";
    homepage = "https://cloud.tencent.com/product/tat";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
