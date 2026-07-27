{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  withGui ? true,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  __structuredAttrs = true;

  pname = "birdnet-analyzer";
  version = "2.4.0-unstable-2026-05-11";

  # Using an unstable version because an older version was touching the
  # RO nix store
  src = fetchFromGitHub {
    owner = "birdnet-team";
    repo = "BirdNET-Analyzer";
    rev = "3e9392dfde272aaa3929cc3f1d7b100b574abd36";
    hash = "sha256-6FSPGXIS5N1L+j29qi1J1lqfVoC/tcVFFc9dnmkTQwk=";
  };

  # Tell it to always use the APPDIR
  postPatch = ''
    substituteInPlace birdnet_analyzer/gui/settings.py birdnet_analyzer/gui/utils.py \
      --replace-fail "utils.FROZEN" "True"
  '';

  pyproject = true;

  build-system = [
    python3Packages.setuptools
  ];

  dependencies =
    with python3Packages;
    [
      # Base deps
      librosa
      resampy
      tensorflow
      pyarrow
      tqdm
      pandas
      matplotlib
      birdnet
    ]
    ++ lib.optionals withGui (
      [
        # Training deps
        optuna
        # Embedding deps
        # Still need to test if this is required as it's not packaged in nixpkgs atm
        # perch-hoplite
        # gui deps
        gradio
        pywebview
        plotly
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        qtpy
        pygobject3
      ]
      ++ plotly.optional-dependencies.express
    );

  makeWrapperArgs = [
    "--set-default"
    "GUI_VERSION"
    finalAttrs.version
  ];

  meta = {
    homepage = "https://birdnet.cornell.edu/birdnet";
    downloadPage = "https://github.com/birdnet-team/BirdNET-Analyzer/releases";
    changelog = "https://github.com/birdnet-team/BirdNET-Analyzer/releases/tag/v${finalAttrs.version}";
    mainProgram = "birdnet-analyzer";
    license = [
      lib.licenses.mit
    ];
    maintainers = [
      lib.maintainers.RossSmyth
    ];
  };

})
