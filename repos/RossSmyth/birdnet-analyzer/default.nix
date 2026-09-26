{
  lib,
  stdenv,
  python313Packages,
  fetchFromGitHub,
  withGui ? true,
}:
let
  python3Packages = python313Packages;
in
python3Packages.buildPythonApplication (finalAttrs: {
  __structuredAttrs = true;

  pname = "birdnet-analyzer";
  version = "2.4.0-unstable-2026-09-08";

  # Using an unstable version because an older version was touching the
  # RO nix store
  src = fetchFromGitHub {
    owner = "birdnet-team";
    repo = "BirdNET-Analyzer";
    rev = "df2ad1ce40415721397586832e04b6cb7d51079f";
    hash = "sha256-ckx4oT1RE1PnPBvxGG8Ljm+km6jeURa0FIlUYi28TBI=";
  };

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
      tensorflowWithoutCuda
      pyarrow
      tqdm
      pandas
      matplotlib
      birdnet
      keras
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
