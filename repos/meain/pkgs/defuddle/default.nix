{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "defuddle";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "kepano";
    repo = "defuddle";
    rev = version;
    hash = "sha256-Fn203XKjZ2qbM1o0zs6mgxCdjWLOwz9Na+s1WSQG9XM=";
  };

  npmDepsHash = "sha256-quqWhbcaSNj4Bk++4N4LYq3Y8U5nQqnwc+MqU0LLgso=";

  # jsdom is a peerDependency needed at runtime for the CLI
  dontNpmPrune = true;

  meta = {
    description = "Extract the main content from web pages";
    homepage = "https://github.com/kepano/defuddle";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "defuddle";
  };
}
