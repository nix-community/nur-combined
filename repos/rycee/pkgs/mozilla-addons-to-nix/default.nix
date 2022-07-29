{ fetchFromSourcehut, mkDerivation, aeson, base, directory, hnix, lib
, microlens-aeson, microlens-platform, relude, wreq }:

let version = "0.9.0";
in mkDerivation {
  pname = "mozilla-addons-to-nix";
  inherit version;
  src = fetchFromSourcehut {
    owner = "~rycee";
    repo = "mozilla-addons-to-nix";
    rev = "v${version}";
    hash = "sha256-37hNhf7ZMwsHB5f2tP49fUTCn7ZowQAO9CIh1SMmbkA=";
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
