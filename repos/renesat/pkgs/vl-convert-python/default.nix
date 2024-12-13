{
  fetchFromGitHub,
  rustPlatform,
  buildPythonPackage,
  callPackage,
  protobuf,
  pytestCheckHook,
  scikit-image,
}:
buildPythonPackage rec {
  pname = "vl-convert-python";
  version = "1.7.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "vega";
    repo = "vl-convert";
    rev = "v${version}";
    hash = "sha256-dmfY05i5nCiM2felvBcSuVyY8G70HhpJP3KrRGQ7wq8=";
  };

  buildAndTestSubdir = "vl-convert-python";

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-23t2aauiLBiFY6zENrqHJNr57H43H2/TtLLajqCvtXY=";
  };

  buildInputs = [protobuf];

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    scikit-image
  ];

  pythonImportsCheck = ["vl_convert"];

  disabledTestPaths = [
    # Tests requires pypdfium2
    "vl-convert-python/tests/test_specs.py"
  ];

  RUSTY_V8_ARCHIVE = callPackage ./librusty_v8.nix {};
}
