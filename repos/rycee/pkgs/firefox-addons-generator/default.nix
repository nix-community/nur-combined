{ aeson, base-noprelude, directory, fetchFromGitLab, hnix, lib, microlens-aeson
, microlens-platform, mkDerivation, relude, text, wreq }:

mkDerivation rec {
  pname = "nixpkgs-firefox-addons";
  version = "0.8.0";
  src = fetchFromGitLab {
    owner = "rycee";
    repo = "nixpkgs-firefox-addons";
    rev = "v${version}";
    sha256 = "0f5d1r4vvxpa3rv3kyahaidm6mv39ip1d1fdkc5c0a38qcc5chvq";
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
