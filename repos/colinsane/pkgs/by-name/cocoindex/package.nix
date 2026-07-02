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
  version = "1.0.14";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-STxI1OBuySOBZnOUK5UZSn/i32tO6ZWiDhtb+FEbSGo=";
  };

  pyproject = true;

  build-system = [ maturin ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-S7mnxL6qs80+BCar1ZVFlOiV3A69hnSukXDUIWnbeUE=";
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