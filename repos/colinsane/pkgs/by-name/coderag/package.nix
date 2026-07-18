# CodeRAG: local-first semantic code-search engine with MCP support.
# <https://github.com/Neverdecel/CodeRAG>
{
  callPackage,
  fetchFromGitHub,
  lib,
  makeWrapper,
  nix-update-script,
  python3,
  fastembed-model-bge-small-en-v1_5 ? callPackage ./fastembed-model-bge-small-en-v1_5/package.nix { },
}:

python3.pkgs.buildPythonApplication rec {
  pname = "coderag";
  version = "1.0.0-unstable-2025-07-29";

  src = fetchFromGitHub {
    owner = "Neverdecel";
    repo = "CodeRAG";
    rev = "ab0bb12de93506d4b979977b380b80e46128a21e";
    hash = "sha256-Fs0u/UiCl4JJfmNo0nfeM/gAf0JEgwAEH7OAQ8jxY7o=";
  };

  pyproject = true;

  build-system = with python3.pkgs; [
    setuptools
    wheel
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postPatch = ''
    # upstream requires setuptools>=82.0.1; nixpkgs ships 80.x, which still works.
    substituteInPlace pyproject.toml --replace-fail 'setuptools>=82.0.1' 'setuptools>=80.0.0'

    # Index Nix files too. Upstream's language map lacks .nix, so these would otherwise
    # be silently skipped unless --all-text is passed everywhere.
    substituteInPlace coderag/chunking/languages.py --replace-fail \
      '".gradle": "gradle",' \
      $'".gradle": "gradle",\n    ".nix": "nix",'
  '';

  patches = [
    ./global-store-dir.patch
  ];

  dependencies = with python3.pkgs; [
    lancedb
    pylance
    pyarrow
    numpy
    python-dotenv
    tenacity
    watchdog
    fastembed
    pathspec
    tree-sitter
    tree-sitter-python
    tree-sitter-javascript
    tree-sitter-grammars.tree-sitter-typescript
    tree-sitter-grammars.tree-sitter-go
    tree-sitter-rust
    tree-sitter-grammars.tree-sitter-java
    tqdm
  ];

  optional-dependencies = {
    server = with python3.pkgs; [
      fastapi
      uvicorn
    ];
    ui = with python3.pkgs; [
      fastapi
      uvicorn
      jinja2
      pygments
    ];
    mcp = with python3.pkgs; [
      mcp
    ];
    openai = with python3.pkgs; [
      openai
    ];
    anthropic = with python3.pkgs; [
      anthropic
    ];
  };

  # all extras except gpu (onnxruntime-gpu is not typically in nixpkgs)
  propagatedBuildInputs = with python3.pkgs; lib.optionals (!stdenv.hostPlatform.isAarch32) (
    optional-dependencies.server
    ++ optional-dependencies.ui
    ++ optional-dependencies.mcp
    ++ optional-dependencies.openai
    ++ optional-dependencies.anthropic
  );

  pythonImportsCheck = [
    "coderag"
    "coderag.surfaces.cli"
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytest
    pytest-cov
    httpx
  ];

  doCheck = true;

  # relax runtime deps that are slightly older in nixpkgs but functionally compatible
  pythonRelaxDeps = [
    "fastapi"
    "lancedb"
    "numpy"
    "pylance"
    "pyarrow"
    "tenacity"
    "tqdm"
    "tree-sitter-rust"
    "uvicorn"
    "watchdog"
  ];

  postFixup = ''
    wrapProgram $out/bin/coderag \
      --set-default CODERAG_CACHE_DIR ${fastembed-model-bge-small-en-v1_5}
  '';

  passthru = {
    inherit fastembed-model-bge-small-en-v1_5;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Local-first semantic code-search engine for large and custom codebases";
    homepage = "https://github.com/Neverdecel/CodeRAG";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "coderag";
  };
}
