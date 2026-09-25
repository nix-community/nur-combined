{
  lib,
  fetchurl,
  fetchFromGitHub,
  python3Packages,
}:
let
  pname = "google-colab-cli";
  version = "0.7.2";

  jupyter-mimetypes = python3Packages.buildPythonPackage rec {
    pname = "jupyter-mimetypes";
    version = "0.2.0";
    format = "wheel";

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/72/45/cb4671e13fed39f721066ad1a00714d4b607982b8d3e97a25f836198d1df/jupyter_mimetypes-0.2.0-py3-none-any.whl";
      hash = "sha256-5tzZiSWOP8lENltlbZFzGRUX4OOTvYeOl85QDls4hSc=";
    };

    propagatedBuildInputs = with python3Packages; [
      pyarrow
      typing-extensions
    ];
  };

  jupyter-kernel-client = python3Packages.buildPythonPackage rec {
    pname = "jupyter-kernel-client";
    version = "unstable-2026-01-30";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "googlecolab";
      repo = "jupyter-kernel-client";
      rev = "f18e982c3265df5e923aa9def101ab3fd737e139";
      hash = "sha256-A2c78qPdY5HIdAmcr1PP3UbtMty84zrNnvZItu7Rk+E=";
    };

    nativeBuildInputs = with python3Packages; [
      hatchling
    ];

    propagatedBuildInputs = with python3Packages; [
      jupyter-core
      jupyter-client
      jupyter-mimetypes
      requests
      traitlets
      typing-extensions
      websocket-client
    ];

    # jupyter-mimetypes is required by jupyter-kernel-client? Wait, let's verify.
    # Ah, the pyproject.toml of jupyter-kernel-client required `jupyter-mimetypes`.
    # Let me check if I can just omit it or if I need to mock it.
    # Actually, I should also build jupyter-mimetypes.
  };

in
python3Packages.buildPythonApplication {
  inherit pname version;
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "googlecolab";
    repo = "google-colab-cli";
    rev = "e25c2655c7ff2fffb7e6c493c51a910d5c461a0b";
    hash = "sha256-wScCy1ykGlyeTGUHi6dMMWjqiG8eq8f1MJZazBPKnpE=";
  };

  nativeBuildInputs = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  propagatedBuildInputs = with python3Packages; [
    click
    filelock
    google-auth
    google-auth-oauthlib
    html2text
    jupyter-kernel-client
    nbformat
    packaging
    prompt-toolkit
    pydantic
    pygments
    requests
    rich
    typer
    typing-extensions
    websocket-client
  ];

  # The tests might require network or additional setup
  doCheck = false;

  meta = with lib; {
    description = "CLI for interacting with Colab";
    homepage = "https://github.com/googlecolab/google-colab-cli";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "colab";
  };
}
