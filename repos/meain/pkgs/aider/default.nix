{
  lib,
  stdenv,
  python311,
  fetchFromGitHub,
  gitMinimal,
  portaudio,
}:

let
  python3 = python311.override {
    self = python3;
    packageOverrides = _: super: { tree-sitter = super.tree-sitter_0_21; };
  };
  version = "0.74.3.dev";
  aider-chat = python3.pkgs.buildPythonApplication {
    pname = "aider-chat";
    inherit version;
    pyproject = true;

    src = fetchFromGitHub {
      owner = "Aider-AI";
      repo = "aider";
      rev = "refs/tags/v${version}";
      hash = "sha256-DzHbvpKYXQdjC84gRkfci2ehR1hGkoLOGOvNYVnMJpE=";
    };

    pythonRelaxDeps = true;

    build-system = with python3.pkgs; [ setuptools-scm pip ];

    dependencies = with python3.pkgs; [
      aiohappyeyeballs
      aiohttp
      aiosignal
      annotated-types
      anyio
      attrs
      backoff
      beautifulsoup4
      certifi
      cffi
      charset-normalizer
      click
      configargparse
      diff-match-patch
      diskcache
      distro
      filelock
      flake8
      frozenlist
      fsspec
      gitdb
      gitpython
      grep-ast
      h11
      httpcore
      httpx
      huggingface-hub
      idna
      importlib-resources
      jinja2
      jiter
      json5
      jsonschema
      jsonschema-specifications
      litellm
      markdown-it-py
      markupsafe
      mccabe
      mdurl
      multidict
      networkx
      numpy
      openai
      packaging
      pathspec
      pexpect
      pillow
      prompt-toolkit
      psutil
      ptyprocess
      pycodestyle
      pycparser
      pydantic
      pydantic-core
      pydub
      pyflakes
      pygments
      pypandoc
      pyperclip
      python-dotenv
      pyyaml
      referencing
      regex
      requests
      rich
      rpds-py
      scipy
      smmap
      sniffio
      sounddevice
      soundfile
      soupsieve
      tiktoken
      tokenizers
      tqdm
      tree-sitter
      tree-sitter-languages
      typing-extensions
      urllib3
      watchfiles
      wcwidth
      yarl
      zipp

      # Not listed in requirements
      mixpanel
      monotonic
      posthog
      propcache
      python-dateutil
    ];

    buildInputs = [ portaudio ];

    nativeCheckInputs = (with python3.pkgs; [ pytestCheckHook ]) ++ [ gitMinimal ];

    doCheck = false; # I don't need no damn tests

    makeWrapperArgs = [
      "--set AIDER_CHECK_UPDATE false"
      "--set AIDER_ANALYTICS false"
    ];

    preCheck = ''
      export HOME=$(mktemp -d)
      export AIDER_ANALYTICS="false"
    '';

    optional-dependencies = with python3.pkgs; {
      playwright = [
        greenlet
        playwright
        pyee
        typing-extensions
      ];
    };

    passthru = {
      withPlaywright = aider-chat.overridePythonAttrs (
        { dependencies, ... }:
        {
          dependencies = dependencies ++ aider-chat.optional-dependencies.playwright;
        }
      );
    };

    meta = {
      description = "AI pair programming in your terminal";
      homepage = "https://github.com/paul-gauthier/aider";
      changelog = "https://github.com/paul-gauthier/aider/blob/v${version}/HISTORY.md";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ taha-yassine ];
      mainProgram = "aider";
    };
  };
in
aider-chat
