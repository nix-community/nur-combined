{ aeson, base-noprelude, directory, fetchFromGitLab, hnix, lib, microlens-aeson
, microlens-platform, mkDerivation, relude, text, wreq, ... }@inputs:

mkDerivation rec {
  # __contentAddressed = true;
  pname = "nixpkgs-firefox-addons";
  version = "0.8.1";
  # src = inputs.firefox-addons-generator;
  src = fetchFromGitLab {
    owner = "rycee";
    repo = "nixpkgs-firefox-addons";
    rev = "v${version}";
    sha256 = "pwEJESWamrnbwv6vMoczciFIaew3uf5MYTqd0E5wE3o=";
  };
  isLibrary = false;
  isExecutable = true;
  enableSeparateDataOutput = true;
  executableHaskellDepends = [
    aeson
    base-noprelude
    directory
    hnix
    microlens-aeson
    microlens-platform
    relude
    text
    wreq
  ];
  homepage = "https://gitlab.com/rycee/nix-firefox-addons";
  description = "Tool generating a Nix package set of Firefox addons";
  license = lib.licenses.gpl3;
  maintainers = with lib.maintainers; [ rycee ];
}
