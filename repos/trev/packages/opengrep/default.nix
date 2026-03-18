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
  version = "1.16.5";

  binaries = {
    aarch64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_aarch64.tar.gz";
      hash = "sha256-KT5sWsHWPe1VAkDs2qJit6Xxz92HF7t4aaxMu3j8n9s=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_x86.tar.gz";
      hash = "sha256-El2PY+PAqsfNyquZRF2DkwMhmUx1DPahYgI3/30IiBM=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_osx_aarch64.tar.gz";
      hash = "sha256-gG8hd8+KH6LCo/sQ6wb78o77VRiAbTsqgTa/OGi1sYY=";
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
    hash = "sha256-IPrtZwio5/nf/TUrs5hraI0gRjFKmOf+Pd78bgV+5Lc=";
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
