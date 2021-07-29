{ aeson
, base-noprelude
, directory
, fetchFromGitHub
, hnix
, lib
, microlens-aeson
, microlens-platform
, mkDerivation
, relude
, text
, wreq
, sources
}:

mkDerivation rec {
  pname = "nixpkgs-firefox-addons";
  version = "0.8.0";
  src = fetchFromGitHub { inherit (sources.nixpkgs-firefox-addons) owner repo rev sha256; };
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

