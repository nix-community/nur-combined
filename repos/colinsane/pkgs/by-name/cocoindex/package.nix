# CocoIndex: incremental engine for data transformation and indexing.
# <https://github.com/cocoindex-io/cocoindex>
{
  lib,
  rustPlatform,
  fetchPypi,
  python3,
  maturin,
  nix-update-script,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "cocoindex";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-DRL8meaOVAoox5Yu3mBDIXPbHLWqEfezR+JuVSvW4zU=";
  };

  pyproject = true;

  build-system = [ maturin ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-IREP8v5XQ3zyy3IGKzSeaTlhA1y0k+pHurPGadFaVZ0=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  dependencies = with python3.pkgs; [
    typing-extensions
    click
    rich
    python-dotenv
    watchdog
    numpy
    psutil
    msgspec
  ];

  pythonImportsCheck = [ "cocoindex" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Incremental engine for data transformation and indexing";
    homepage = "https://github.com/cocoindex-io/cocoindex";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ colinsane ];
  };
}