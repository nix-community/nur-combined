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
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-yrt+JFv9yu7xyACeC4wLCVtwJn1MyWNqYNQiOt7dM98=";
  };

  pyproject = true;

  build-system = [ maturin ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-V1Ilhi0KW6dyMXEbxJaSHSRDwd02bTfLx7YezPkuzpg=";
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
    platforms = lib.platforms.linux;
  };
}
