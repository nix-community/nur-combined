{
  autoPatchelfHook,
  fetchFromGitHub,
  fetchurl,
  lib,
  nix-update-script,
  python3Packages,
  stdenv,
}: let
  pname = "opengrep";
  version = "1.11.5";

  binaries = {
    # aarch64-linux = fetchurl {
    #   url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_aarch64.tar.gz";
    #   hash = "sha256-H09X7sEsL+1DXPT03jqUYv9I0GrlcO5XvKNPCAUyiJE=";
    # };
    x86_64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_x86.tar.gz";
      hash = "sha256-ZC/Lb1hXMVmMy66jCyCqiEL5yvc2La7ed69FP5gStkE=";
    };
    # aarch64-darwin = fetchurl {
    #   url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_osx_aarch64.tar.gz";
    #   hash = "sha256-CCzprXv74B98oxz8SiLkN/Hs2WWLsUXmEVHTEjfc9cs=";
    # };
    # x86_64-darwin = fetchurl {
    #   url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_osx_x86.tar.gz";
    #   hash = "sha256-GsqPGONZ8BEuEYS3tsndltDO741SklrLwZtGKId15VM=";
    # };
  };

  core = stdenv.mkDerivation {
    pname = "${pname}-core";
    inherit version;

    src = binaries."${stdenv.hostPlatform.system}" or (throw "unsupported system: ${stdenv.hostPlatform.system}");

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -m755 -D opengrep-core $out/bin/opengrep-core
      runHook postInstall
    '';
  };
in
  python3Packages.buildPythonApplication {
    inherit core pname version;
    pyproject = true;

    src = fetchFromGitHub {
      owner = "opengrep";
      repo = "opengrep";
      tag = "v${version}";
      hash = "sha256-/dY/CC5VafxkAdGR9ZlAVoAtFmHeNvTaEBwSfOZlhi0=";
      fetchSubmodules = true;
    };

    build-system = with python3Packages; [
      setuptools
    ];

    pythonRelaxDeps = [
      "boltons"
      "defusedxml"
      "exceptiongroup"
      "glom"
      "rich"
      "tomli"
      "wcmatch"
    ];

    dependencies = with python3Packages; [
      attrs
      boltons
      click
      click-option-group
      colorama
      defusedxml
      exceptiongroup
      glom
      jaraco-text
      jsonschema
      packaging
      peewee
      protobuf
      requests
      rich
      ruamel-yaml
      tomli
      tqdm
      typing-extensions
      urllib3
      wcmatch
    ];

    postPatch = ''
      cd cli
    '';

    preFixup = ''
      makeWrapperArgs+=(--prefix PATH : ${core}/bin)
    '';

    passthru = {
      updateScript = lib.concatStringsSep " " (nix-update-script {
        extraArgs = [
          "--commit"
          "--subpackage core"
          "${pname}"
        ];
      });
    };

    meta = {
      homepage = "https://github.com/opengrep/opengrep";
      mainProgram = "opengrep";
      changelog = "https://github.com/opengrep/opengrep/releases/tag/v${version}";
      description = "Static code analysis engine to find security issues in code";
      license = lib.licenses.lgpl21Plus;
      platforms = lib.attrNames binaries;
    };
  }
