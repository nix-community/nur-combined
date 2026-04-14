{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "davey";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "Snazzah";
    repo = "davey";
    tag = "py-${version}";
    hash = "sha256-WR8OBYZXNxFfToVn0ZNkacZPN04w/y3tCK6/xCP50gI=";
  };

  pyproject = true;

  buildAndTestSubdir = "davey-python";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname src version;
    hash = "sha256-kLLOuwGCfkByXt6LW8vGxS1JYQW+r/tW7dOiKx6M4k4=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  pythonImportsCheck = [ "davey" ];

  nativeCheckInputs = [ pytestCheckHook ];

   meta = {
    description = "Discord DAVE implementation in Rust";
    homepage = "https://github.com/Snazzah/davey";
    changelog = "https://github.com/Snazzah/davey/releases/tag/py-${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}
