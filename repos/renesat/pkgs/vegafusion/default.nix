{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
  # Deps
  narwhals,
  arro3-core,
  protobuf,
}:
buildPythonPackage rec {
  pname = "vegafusion";
  version = "2.0.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "hex-inc";
    repo = "vegafusion";
    rev = "v${version}";
    hash = "sha256-C0PInGAutgCcjaKFiUI5ClMTR6/uvhcMZCtILWBwSF0=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-w7rvnnfGukMqdwHaycp3rJ2R2HTvhD3D/608MjJ1oCY=";
  };

  buildAndTestSubdir = "vegafusion-python";

  buildInputs = [protobuf];

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  dependencies = [
    narwhals
    arro3-core
  ];

  pythonImportsCheck = ["vegafusion"];

  meta = with lib; {
    description = "Core tools for using VegaFusion from Python";
    homepage = "https://github.com/hex-inc/vegafusion";
    license = lib.licenses.bsd3;
    maintainers = with maintainers; [renesat];
  };
}
