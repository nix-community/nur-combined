{ fetchFromSourcehut, mkDerivation, aeson, base, directory, hnix, lib
, microlens-aeson, microlens-platform, relude, wreq }:

let version = "0.10.0";
in mkDerivation {
  pname = "mozilla-addons-to-nix";
  inherit version;
  src = fetchFromSourcehut {
    owner = "~rycee";
    repo = "mozilla-addons-to-nix";
    rev = "v${version}";
    hash = "sha256-IolGnrsHSR9FQ6sO/40r+9XLBiP1QwlLTrAHOAXiZ4Q=";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson
    base
    directory
    hnix
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
