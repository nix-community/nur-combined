{ fetchFromGitHub }:

rec {
  version = "0.21.0";
  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "delta-nix";
    tag = "v${version}";
    hash = "sha256-xeYPpllCLZYRON/kzmROZr9Zt+0jpyv/p5BdIkUSYYU=";
  };
}
