{
  system,
  lib,
  fetchFromGitHub,
  buildPythonApplication,
  setuptools,
  fetchurl,
  stdenv,
  autoPatchelfHook,
  nix-update-script,
  # python packages
  attrs,
  boltons,
  click,
  click-option-group,
  colorama,
  defusedxml,
  exceptiongroup,
  glom,
  jsonschema,
  packaging,
  peewee,
  requests,
  rich,
  ruamel-yaml,
  tomli,
  tqdm,
  typing-extensions,
  urllib3,
  wcmatch,
  protobuf,
  jaraco-text,
}: let
  pname = "opengrep";
  version = "1.8.2";

  binaries = {
    aarch64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_aarch64.tar.gz";
      hash = "sha256-xTk2I7omfN7nUlTHOQBAClF1CTjedUUGJt/75VYWp2E=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_x86.tar.gz";
      hash = "sha256-9LWfO4owQffGBkxlWfa0e36KIwM5t+xs/w1lOGM/2D8=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_osx_aarch64.tar.gz";
      hash = "sha256-pvdbaT0zumGl6JYxuDvqyC7CGnVAdHrUToX+K97zNT8=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_osx_x86.tar.gz";
      hash = "sha256-uWY5gZtKO1DSaNaX0ydEhbu/4XWU1OzrdIPVT6mOQbE=";
    };
  };

  core = stdenv.mkDerivation {
    pname = "${pname}-core";
    inherit version;

    src = binaries."${system}";

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
  buildPythonApplication {
    inherit core pname version;

    src = fetchFromGitHub {
      owner = "opengrep";
      repo = "opengrep";
      tag = "v${version}";
      hash = "sha256-INi84Z5y3TY+p4w3zmf04LjlnCXe0/8ClFjUBbT3HU0=";
      fetchSubmodules = true;
    };

    postPatch = ''
      cd cli
    '';

    pyproject = true;
    build-system = [setuptools];

    pythonRelaxDeps = [
      "boltons"
      "defusedxml"
      "exceptiongroup"
      "glom"
      "rich"
      "tomli"
      "wcmatch"
    ];

    # coupling: anything added to the pysemgrep setup.py should be added here
    propagatedBuildInputs = [
      attrs
      boltons
      click
      click-option-group
      colorama
      defusedxml
      exceptiongroup
      glom
      jsonschema
      packaging
      peewee
      requests
      rich
      ruamel-yaml
      tomli
      tqdm
      typing-extensions
      urllib3
      wcmatch
      protobuf
      jaraco-text
    ];

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
      description = "Static code analysis engine to find security issues in code.";
      license = lib.licenses.lgpl21Plus;
      platforms = lib.attrNames binaries;
    };
  }
