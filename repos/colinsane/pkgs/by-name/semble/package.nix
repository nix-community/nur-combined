{
  fetchFromGitHub,
  fetchgit,
  gitUpdater,
  lib,
  makeWrapper,
  model2vec,
  python3,
  semble-grammars,
  stdenv,
  vicinity,
}:

let
  # recommended model, per <https://github.com/MinishLab/semble#how-it-works>
  # but could use any model2vec-compatible model
  potion-code-16M-v2 = fetchgit {
    url = "https://huggingface.co/minishlab/potion-code-16M-v2";
    rev = "e9d2a44ca6a05ac6685f3b23709ea57eb7352d5b";
    hash = "sha256-eDhIHP4S6yVSpZH8SmXcfRXbYookLNM9xX0Mg5gC5iM=";
    fetchLFS = true;
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "semble";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "MinishLab";
    repo = "semble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nODZ1Rnw1XVCB4ADzlVtr2TONBeb3D4Ut86qhUfCTHQ=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = [
    model2vec
    python3.pkgs.mcp
    python3.pkgs.numpy
    python3.pkgs.orjson
    python3.pkgs.pathspec
    python3.pkgs.questionary
    semble-grammars
    vicinity
  ];

  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [ "semble" ];

  makeWrapperArgs = [
    "--set" "SEMBLE_MODEL_NAME" "${potion-code-16M-v2}"
    "--set" "SEMBLE_GRAMMARS_CACHE_DIR" "${semble-grammars}/lib/${python3.libPrefix}/site-packages/semble_grammars/grammars"
  ];

  postFixup = ''
    wrapPythonPrograms
  '';

  doCheck = true;

  passthru = {
    inherit potion-code-16M-v2;
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Fast and accurate code search for agents";
    homepage = "https://github.com/MinishLab/semble";
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "semble";
  };
})
