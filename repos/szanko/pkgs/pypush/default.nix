{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pypush";
  version = "2.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "JJTech0130";
    repo = "pypush";
    rev = "v${version}";
    hash = "sha256-gXnUzIM7/AZYZNrxgxnFfuowHxIq1ZROm0aGbUCoO7g=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    anyio
    cryptography
    exceptiongroup
    httpx
    importlib-metadata
    typing-extensions
    rich
    frida-python
    typer-slim
  ];

  optional-dependencies = with python3.pkgs; {
    cli = [
      frida-python
      rich
      typer
    ];
    test = [
      pytest
      pytest-asyncio
    ];
  };

  postInstall = ''
    # bash
    mkdir -p $out/share/bash-completion/completions
    $out/bin/pypush --show-completion bash > $out/share/bash-completion/completions/pypush

    # zsh
    mkdir -p $out/share/zsh/site-functions
    $out/bin/pypush --show-completion zsh > $out/share/zsh/site-functions/_pypush

    # fish
    mkdir -p $out/share/fish/completions
    $out/bin/pypush --show-completion fish > $out/share/fish/completions/_pypush

  '';

  pythonImportsCheck = [
    "pypush"
  ];

  meta = {
    description = "Python APNs and iMessage client";
    homepage = "https://github.com/JJTech0130/pypush.git";
    license = lib.licenses.sspl;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "pypush";
  };
}
