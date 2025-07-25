{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  testers,
# nix-update-script,
}:
let
  wikidata-rdf-patch = python3Packages.buildPythonApplication rec {
    pname = "wikidata-rdf-patch";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "wikidata-rdf-patch";
      tag = "v${version}";
      hash = "sha256-Asoylv5gPJLfiKu617rKrv6wT8AJxQB1pf/uoEr9T84=";
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
      # FIXME: Broken on nixos-25.05
      broken = python3Packages.click.version == "8.1.8";
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
      # updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

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
