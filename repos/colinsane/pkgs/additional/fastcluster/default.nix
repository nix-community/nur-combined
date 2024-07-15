{
  lib,
  fetchFromGitHub,
  python3,
  stdenv,
}: stdenv.mkDerivation (finalAttrs: {
  pname = "fastcluster";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "fastcluster";
    repo = "fastcluster";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8FDipkAcOAI5zAC7JaJExe6HO1xHg+eXAL7IUIVrA3k=";
  };

  nativeBuildInputs = [
    python3.pythonOnBuildForHost.pkgs.oldest-supported-numpy
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.setuptoolsBuildHook
  ];

  propagatedBuildInputs = with python3.pkgs; [
    numpy
  ];

  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [
    "fastcluster"
  ];

  doCheck = true;
  strictDeps = true;

  meta = with lib; {
    homepage = "https://danifold.net/fastcluster.html";
    description = "fast hierarchical clustering routines for R and Python";
    maintainers = with maintainers; [ colinsane ];
  };
})
