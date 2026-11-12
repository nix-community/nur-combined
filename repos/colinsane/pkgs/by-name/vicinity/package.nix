{
  fetchFromGitHub,
  gitUpdater,
  python3,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vicinity";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "MinishLab";
    repo = "vicinity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6yEpHfNXkul8rkvmFU38gerYoCBIxdU32qFIz7EysOM=";
  };

  nativeBuildInputs = [
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
  ];
  propagatedBuildInputs = [
    python3.pkgs.numpy
    python3.pkgs.orjson
    python3.pkgs.tqdm
  ];

  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  doCheck = true;

  pythonImportsCheck = [ "vicinity" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };
})
