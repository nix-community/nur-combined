{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "wikidata-rdf-patch";
  version = "1.0.3";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "wikidata-rdf-patch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D20bjpiiG/3ooXxUSfjnr9of9uEu2zA2nyVraSklPAs=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    click
    rdflib
    tqdm
  ];

  doCheck = false;

  pythonImportsCheck = [
    "wikidata_rdf_patch.cli"
    "wikidata_rdf_patch.rdf_patch"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Edit Wikidata items with RDF";
    homepage = "https://github.com/josh/wikidata-rdf-patch";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
