{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "4at";
  version = "0-unstable-2023-12-07";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "4at";
    rev = "9b5075cd08ba5ec1236822a1dea288d47975ca27";
    hash = "sha256-H+fwJnQ6xAO7tnodiKGJcwyF9/ddqbWUtJtIgb3a9mM=";
  };

  fixupPhase = ''
    mv $out/bin/{,4at-}server
    mv $out/bin/{,4at-}client
    mv $out/bin/{,4at-}pandora
  '';

  doCheck = false;

  cargoHash = "sha256-aMrauF7/imNe7YouUS2OUeY0KPKTn6X0dYRahVwM3Rw=";

  meta = {
    description = "Simple Multi-User Chat";
    homepage = "https://github.com/tsoding/4at";
    license = lib.licenses.mit;
    mainProgram = "4at-client";
  };
}
