{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  testers,
  nix-update-script,
}:
let
  wikidata-rdf-patch = python3Packages.buildPythonApplication rec {
    pname = "wikidata-rdf-patch";
    version = "0.1.2";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "wikidata-rdf-patch";
      tag = "v${version}";
      hash = "sha256-dAiMab3yzMiI/dacDn+wXjkUEU3oeYRczkgYjQJFZAE=";
    };

    pyproject = true;
    __structuredAttrs = true;

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      click
      rdflib
      tqdm
    ];

    meta = {
      description = "Edit Wikidata items with RDF";
      homepage = "https://github.com/josh/wikidata-rdf-patch";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "wikidata-rdf-patch";
    };
  };
in
wikidata-rdf-patch.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    wikidata-rdf-patch = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

      tests = {
        version = testers.testVersion {
          package = wikidata-rdf-patch;
          inherit (finalAttrs) version;
        };

        help =
          runCommand "test-wikidata-rdf-patch-help"
            {
              __structuredAttrs = true;
              nativeBuildInputs = [ wikidata-rdf-patch ];
            }
            ''
              wikidata-rdf-patch --help
              touch $out
            '';
      };
    };
  }
)
