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
  version = "1.32.0";

  binaries = {
    aarch64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_aarch64.tar.gz";
      hash = "sha256-C+a6SzLNlNdrL+JF3mo5FsSyzXvbETiGAvrnnJAU6Io=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_x86.tar.gz";
      hash = "sha256-k5s0GQAkmgPqVZFIz9AjzU1LtGVN7sdw9lw0Sq1j5tE=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_osx_aarch64.tar.gz";
      hash = "sha256-Jy37Esy6aZl0jejZSnjETMy4H+VZDsV7dRnKdCr5Pkg=";
    };
  };

  core = stdenv.mkDerivation {
    pname = "${pname}-core";
    inherit version;

    src =
      binaries."${stdenv.hostPlatform.system}"
        or (throw "unsupported system: ${stdenv.hostPlatform.system}");

    nativeBuildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ autoPatchelfHook ];

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
    hash = "sha256-4dm4DcMTSjsHgHyWA8WxG2rrtdCVl/54CgMAosqde8E=";
    fetchSubmodules = true;
  };

  build-system = [
    setuptools
  ];

  pythonRelaxDeps = [
    "boltons"
    "click"
    "defusedxml"
    "exceptiongroup"
    "glom"
    "peewee"
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
