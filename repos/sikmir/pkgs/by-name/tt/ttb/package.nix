{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "ttb";
  version = "0-unstable-2022-12-14";

  src = fetchFromGitHub {
    owner = "TheOpenDictionary";
    repo = "ttb";
    rev = "535e99f3607ef9b03a2e9b7ef05ab9a78448ef1a";
    hash = "sha256-D5XOqbgpLkUKFOJe9kArARTMd3sM2rOFwJTtwKe6Ypk=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "A lightning-fast tool for querying Tatoebe from the command-line";
    homepage = "https://github.com/TheOpenDictionary/ttb";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "ttb";
    broken = true;
  };
}
