{
  lib
  , buildPythonPackage
  , fetchFromGitHub
  , rustPlatform
}:

buildPythonPackage rec {
  pname = "tantivy";
  version = "0.25.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "quickwit-oss";
    repo = "tantivy-py";
    tag = version;
    hash = "sha256-ZVQOzKojBf7yNkgiOV4huNnuxCmiFwJb610sD4M2/MU=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-/OADcVm01PbHp3bcw62Zt6+9ZmT96Bic+EBbPUhdoOI=";
  };

  build-system = with rustPlatform; [ cargoSetupHook maturinBuildHook ];

  pythonImportsCheck = [ "tantivy" ];

  meta = {
    description = ''
      Python bindings for Tantivy; Tantivy is a full-text search engine library
      inspired by Apache Lucene and written in Rust
    '';
    homepage = "https://github.com/quickwit-oss/tantivy-py";
    changeLog = "https://github.com/quickwit-oss/tantivy-py/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ breakds ];
  };
}
