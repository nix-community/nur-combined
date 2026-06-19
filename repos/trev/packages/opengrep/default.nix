{
  autoPatchelfHook,
  fetchFromGitHub,
  fetchurl,
  lib,
  nix-update-script,
  stdenv,

  # python packages
  attrs,
  boltons,
  buildPythonApplication,
  click-option-group,
  click,
  colorama,
  defusedxml,
  exceptiongroup,
  glom,
  jaraco-text,
  jsonschema,
  packaging,
  peewee,
  protobuf,
  requests,
  rich,
  ruamel-yaml,
  setuptools,
  tomli,
  tqdm,
  typing-extensions,
  urllib3,
  wcmatch,
}:
let
  pname = "opengrep";
  version = "1.23.0";

  binaries = {
    aarch64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_aarch64.tar.gz";
      hash = "sha256-6xv3YIrpE4MFXwZr3Ch0Aub2z+sjBaRrsQ4qGT1KOWU=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_x86.tar.gz";
      hash = "sha256-Oe+eEuNTS5LfnrZ+uwzRut4tPULXCl+3iIR4RB4ZaT4=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_osx_aarch64.tar.gz";
      hash = "sha256-oDJgXwMpGqtM7kWFNvkkEWkRXNdlj9qwos7kI4LsaOU=";
    };
  };

  core = stdenv.mkDerivation {
    pname = "${pname}-core";
    inherit version;

    src =
      binaries."${stdenv.hostPlatform.system}"
        or (throw "unsupported system: ${stdenv.hostPlatform.system}");

    nativeBuildInputs = lib.optionals (!stdenv.isDarwin) [ autoPatchelfHook ];

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
  pyproject = true;

  src = fetchFromGitHub {
    owner = "opengrep";
    repo = "opengrep";
    tag = "v${version}";
    hash = "sha256-hJ0ttebyOAaKj1F3ri0+3Yrwpj0niLrUclbVC1waMgc=";
    fetchSubmodules = true;
  };

  build-system = [
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

  dependencies = [
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "--subpackage core"
      pname
    ];
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
