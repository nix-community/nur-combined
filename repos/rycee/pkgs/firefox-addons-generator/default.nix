{ aeson, base-noprelude, directory, fetchFromGitLab, hnix, lib, microlens-aeson
, microlens-platform, mkDerivation, relude, text, wreq }:

mkDerivation rec {
  pname = "nixpkgs-firefox-addons";
  version = "0.8.1";
  src = fetchFromGitLab {
    owner = "rycee";
    repo = "nixpkgs-firefox-addons";
    rev = "v${version}";
    sha256 = "0yhkf17d179sc56gxf9pxillh8bj6f3k5bzyqbdvk6ls4l8hj0d7";
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
    wreq
  ];
  homepage = "https://gitlab.com/rycee/nix-firefox-addons";
  description = "Tool generating a Nix package set of Firefox addons";
  license = lib.licenses.gpl3;
  maintainers = with lib.maintainers; [ rycee ];
}
