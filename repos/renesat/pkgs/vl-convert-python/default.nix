{
  vl-convert,
  rustPlatform,
  buildPythonPackage,
  protobuf,
  pytestCheckHook,
  scikit-image,
}:
buildPythonPackage rec {
  pname = "vl-convert-python";
  version = "1.7.0";
  format = "pyproject";

  inherit (vl-convert) src;

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

  inherit (vl-convert) RUSTY_V8_ARCHIVE;
}
