{ lib
, fetchFromGitHub
, rustPlatform
}:
let
  pname = "wtfi2";
  version = "0.10.0";
  owner = "kanywst";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-SpC4y7yanwM9HlhsUrfClENgQtuRU/UNGlEaksbz+3E=";
  };

  cargoHash = "sha256-OSB7ZBz/aaEH5aqDOwMU9w3LRzICQ8+Bt6/22CsYd48=";

  # There is no tests
  doCheck = false;

  meta = {
    description = "What The F*ck Internet — a live, visual network path diagnostic that pinpoints exactly where your connection dies.";
    homepage = "https://github.com/kanywst/wtfi2";
    changelog = "https://github.com/kanywst/wtfi2/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "wtfi";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
