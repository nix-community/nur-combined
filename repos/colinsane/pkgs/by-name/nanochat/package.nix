{
  lib,
  fetchFromGitHub,
  python3,
  rustPlatform,
  stdenv,
  maturin,
}:
let
  rustbpe = stdenv.mkDerivation (finalAttrs: {
    pname = "rustbpe";
    version = "0.1.0";
    src = fetchFromGitHub {
      owner = "karpathy";
      repo = "rustbpe";
      rev = "v0.1.0";
      hash = "sha256-mLGp6zc6btnRBqoA0mZm6U8UrDsu1ZBPShwZU1ve/Es=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version src;
      hash = "sha256-VP/EM2oLvleLtQr0p0YgGqcEbNssNZszjKhfIFK2prU=";
    };

    nativeBuildInputs = [
      python3.pkgs.pypaInstallHook
      rustPlatform.cargoSetupHook
      rustPlatform.maturinBuildHook
      maturin
    ];
  });
in
stdenv.mkDerivation {
  pname = "nanochat";
  version = "0.1.0-unstable-2026-07-03";

  src = fetchFromGitHub {
    owner = "karpathy";
    repo = "nanochat";
    rev = "92d63d4e8bb4df75c3b71618f31ddde2378b2bcd";
    hash = "sha256-YsjkGWc9AsNLCBsBwrNJLCNSNXSRM87k8m8ho3x7jFo=";
  };

  nativeBuildInputs = with python3.pkgs; [
    pypaBuildHook
    pypaInstallHook
    setuptoolsBuildHook
    wrapPython
  ];

  nativeCheckInputs = [ python3.pkgs.pythonImportsCheckHook ];

  propagatedBuildInputs = with python3.pkgs; [
    filelock
    kernels
    numpy
    psutil
    pyarrow
    tiktoken
    torch
    rustbpe
  ];

  postPatch = ''
    cat >> pyproject.toml <<'EOF'
    [tool.setuptools.packages.find]
    include = ["nanochat*", "scripts*", "tasks*"]
    EOF
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  pythonImportsCheck = [ "nanochat" ];

  doCheck = true;

  passthru = {
    inherit rustbpe;
    pythonModule = python3;
  };

  meta = {
    description = "The minimal full-stack ChatGPT clone and experimental harness for training LLMs";
    homepage = "https://github.com/karpathy/nanochat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
