# TODO:
# - split into scope
# - add updateScripts
{
  fetchFromGitHub,
  fetchgit,
  lib,
  makeWrapper,
  python3,
  stdenv,
  tree-sitter-grammars,
  writeText,
}:

let
  potion-code-16M-v2 = fetchgit {
    url = "https://huggingface.co/minishlab/potion-code-16M-v2";
    rev = "e9d2a44ca6a05ac6685f3b23709ea57eb7352d5b";
    hash = "sha256-eDhIHP4S6yVSpZH8SmXcfRXbYookLNM9xX0Mg5gC5iM=";
    fetchLFS = true;
  };

  model2vec = stdenv.mkDerivation (finalAttrs: {
    pname = "model2vec";
    version = "0.9.0";

    src = fetchFromGitHub {
      owner = "MinishLab";
      repo = "model2vec";
      tag = "v${finalAttrs.version}";
      hash = "sha256-QuHfsP0p9msVQ1A7YuLo+3VZwYwa3NbUFfh2YpaNQDw=";
    };

    nativeBuildInputs = [
      python3.pkgs.pypaBuildHook
      python3.pkgs.pypaInstallHook
      python3.pkgs.setuptools
      python3.pkgs.setuptools-scm
    ];
    propagatedBuildInputs = [
      python3.pkgs.jinja2
      python3.pkgs.joblib
      python3.pkgs.numpy
      python3.pkgs.safetensors
      python3.pkgs.tokenizers
      python3.pkgs.tqdm
    ];

    nativeCheckInputs = [
      python3.pkgs.pythonImportsCheckHook
    ];

    doCheck = true;

    pythonImportsCheck = [ "model2vec" ];
  });

  vicinity = stdenv.mkDerivation (finalAttrs: {
    pname = "vicinity";
    version = "0.4.4";

    src = fetchFromGitHub {
      owner = "MinishLab";
      repo = "vicinity";
      tag = "v${finalAttrs.version}";
      hash = "sha256-VRDCtPjuuEXeiJ2r4PqCDGnTyYlb3OVeemsN9VrS6Wc=";
    };

    nativeBuildInputs = [
      python3.pkgs.pypaBuildHook
      python3.pkgs.pypaInstallHook
      python3.pkgs.setuptools
      python3.pkgs.setuptools-scm
    ];
    propagatedBuildInputs = [
      python3.pkgs.numpy
      python3.pkgs.orjson
      python3.pkgs.tqdm
    ];

    nativeCheckInputs = [
      python3.pkgs.pythonImportsCheckHook
    ];

    doCheck = true;

    pythonImportsCheck = [ "vicinity" ];
  });

  semble-grammars = stdenv.mkDerivation (finalAttrs: {
    pname = "semble-grammars";
    version = "0.1.2";

    src = fetchFromGitHub {
      owner = "MinishLab";
      repo = "semble-grammars";
      tag = "v${finalAttrs.version}";
      hash = "sha256-kqOfUQTHQIKmASqRhIvBUhrTGFvSG4qtmYAQg4ceyxE=";
    };

    postPatch = let
      # e.g. `linux-x86_64` or `linux-aarch64`
      # lowercase form of `python -c 'import platform; print(f"{platform.system()}-{platform.machine()}")'
      platform = "${stdenv.hostPlatform.parsed.kernel.name}-${stdenv.hostPlatform.parsed.cpu.name}";
      manifest = writeText "manifest.json" (builtins.toJSON {
        inherit platform;
        archive = "";
        languages = lib.listToAttrs (map (pkg:
          let language = lib.replaceStrings [ "-" ] [ "_" ] (lib.removePrefix "tree-sitter-" pkg.pname);
          in {
            name = language;
            value = {
              file = "${pkg}/parser";
              symbol = "tree_sitter_${language}";
              sha256 = "";
            };
          }
        ) tree-sitter-grammars.allGrammars);
      });
    in ''
      mkdir -p src/semble_grammars/grammars/${platform}
      ln -s ${manifest} src/semble_grammars/grammars/${platform}/manifest.json
    '';

    nativeBuildInputs = [
      python3.pkgs.pypaBuildHook
      python3.pkgs.pypaInstallHook
      python3.pkgs.setuptools
      python3.pkgs.setuptools-scm
    ];

    propagatedBuildInputs = [
      python3.pkgs.tree-sitter
    ];
  });
in

stdenv.mkDerivation (finalAttrs: {
  pname = "semble";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "MinishLab";
    repo = "semble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bKPIA/hdgv7rfKptWkXfIW0wKaDc8sD3uCpBKlGahxo=";
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
    inherit
      model2vec
      potion-code-16M-v2
      semble-grammars
      vicinity
      ;
  };

  meta = {
    description = "Fast and accurate code search for agents";
    homepage = "https://github.com/MinishLab/semble";
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "semble";
  };
})
