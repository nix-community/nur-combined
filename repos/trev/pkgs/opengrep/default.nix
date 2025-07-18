{
  lib,
  fetchFromGitHub,
  opengrep-core,
  buildPythonApplication,
  setuptools,
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
  common = import ./common.nix {inherit lib;};
in
  buildPythonApplication {
    pname = "opengrep";
    inherit (common) version;

    src = fetchFromGitHub {
      owner = "opengrep";
      repo = "opengrep";
      tag = "v${common.version}";
      hash = "sha256-d6j3yLFVJq6dB/+eVytJv0qowsYRRBgit5+LiwbLBcU=";
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
      makeWrapperArgs+=(--prefix PATH : ${opengrep-core}/bin)
    '';

    meta =
      common.meta
      // {
        description = common.meta.description + " - cli";
        mainProgram = "opengrep";
        inherit (opengrep-core.meta) platforms;
      };
  }
