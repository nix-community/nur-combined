{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "defuddle";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "kepano";
    repo = "defuddle";
    rev = version;
    hash = "sha256-MtDvNM/NIC/PIcTYEJ77hcvhfu6+fBXIh+36ogqkDx8=";
  };

  npmDepsHash = "sha256-1N2YALmeRCPb1qlzt3xQ+jAD45T2lTGKl7PSAGn8LUQ=";

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
