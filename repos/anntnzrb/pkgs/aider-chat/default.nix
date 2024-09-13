{ pkgs
}:
let
  inherit (pkgs) lib;
  python3 = pkgs.python311.override {
    self = python3;
    packageOverrides = _: super: {
      tree-sitter = super.tree-sitter_0_21;
    };
  };
  version = "0.56.0";
in
python3.pkgs.buildPythonApplication {
  pname = "aider-chat";
  inherit version;
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "paul-gauthier";
    repo = "aider";
    rev = "refs/tags/v${version}";
    hash = "sha256-e0Fqj67vYt41Zbr1FN2fuLp6cHRius8RtacBHLgB9dM=";
  };

  build-system = with python3.pkgs; [ setuptools-scm ];

  dependencies = with python3.pkgs; [
    aiohappyeyeballs
    backoff
    beautifulsoup4
    configargparse
    diff-match-patch
    diskcache
    flake8
    gitpython
    grep-ast
    importlib-resources
    jiter
    json5
    jsonschema
    litellm
    networkx
    numpy
    packaging
    pathspec
    pexpect
    pillow
    playwright
    prompt-toolkit
    ptyprocess
    pypager
    pypandoc
    pyperclip
    pyyaml
    rich
    scipy
    sounddevice
    soundfile
    streamlit
    tokenizers
    toml
    watchdog
  ]
  ++ lib.optionals (!tensorflow.meta.broken) [
    llama-index-core
    llama-index-embeddings-huggingface
  ];

  buildInputs = [ pkgs.portaudio ];

  pythonRelaxDeps = true;

  nativeCheckInputs = (with python3.pkgs; [ pytestCheckHook ]) ++ [ pkgs.gitMinimal ];

  disabledTestPaths = [
    # requires network
    "tests/scrape/test_scrape.py"
    "tests/basic/test_sendchat.py"

    # Expected 'mock' to have been called once
    "tests/help/test_help.py"
  ];

  disabledTests =
    [
      # requires network
      "test_urls"
      "test_get_commit_message_with_custom_prompt"

      # FileNotFoundError
      "test_get_commit_message"

      # Expected 'launch_gui' to have been called once
      "test_browser_flag_imports_streamlit"
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      # fails on darwin
      "test_dark_mode_sets_code_theme"
      "test_default_env_file_sets_automatic_variable"
    ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';
}
