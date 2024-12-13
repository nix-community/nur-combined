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

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-v8NApZw0LYyThuOO++HdbR0eUMJgDR/SeNWAZVKSQfQ=";
  };

  buildAndTestSubdir = "vegafusion-python";

  buildInputs = [protobuf];

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  dependencies = [
    (narwhals.overrideAttrs (_: rec {
      version = "1.16.0";
      src = fetchFromGitHub {
        owner = "narwhals-dev";
        repo = "narwhals";
        tag = "v${version}";
        hash = "sha256-72hwVALYTFNhAnvk9aKxwzP9D5lwk4B9cvan+JIvX/c=";
      };
    }))
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
