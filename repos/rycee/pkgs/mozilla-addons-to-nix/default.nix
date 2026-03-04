{
  fetchFromSourcehut,
  mkDerivation,
  aeson,
  async-pool,
  base,
  directory,
  hnix,
  http-client,
  lib,
  microlens-aeson,
  microlens-platform,
  relude,
  wreq,
}:

let
  pname = "mozilla-addons-to-nix";
  version = "1.0.0";
in
mkDerivation {
  inherit pname version;
  src = fetchFromSourcehut {
    owner = "~rycee";
    repo = pname;
    rev = "81124e855c7eefc903def9537e523d268814590c"; # v${version}";
    hash = "sha256-z8dC2ASauYaa09MyquBJt+AHe+D4Kd6HPHWQ4OjdU2o=";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson
    async-pool
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
