{ fetchFromSourcehut, mkDerivation, aeson, base, directory, hnix, http-client
, lib, microlens-aeson, microlens-platform, relude, wreq }:

let
  pname = "mozilla-addons-to-nix";
  version = "0.11.0";
in mkDerivation {
  inherit pname version;
  src = fetchFromSourcehut {
    owner = "~rycee";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-5RInoqaB8nPjgzCRlKppo3uVxE1y9eaE7yE4lexDZYA=";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson
    base
    directory
    hnix
    http-client
    microlens-aeson
    microlens-platform
    relude
    wreq
  ];
  homepage = "https://git.sr.ht/~rycee/mozilla-addons-to-nix/";
  description = "Tool generating a Nix package set of Firefox addons";
  license = lib.licenses.gpl3Plus;
  mainProgram = "mozilla-addons-to-nix";
  maintainers = with lib.maintainers; [ rycee ];
}
