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
  version = "1.21.0";

  binaries = {
    aarch64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_aarch64.tar.gz";
      hash = "sha256-ExIwW7EaSN/m88RBioWUlc/xus/0/VNdBMm5ppCwKvU=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_x86.tar.gz";
      hash = "sha256-iQxopJb9ochn7cro98DElIg735/S8Q147HcLWs8Cl+I=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_osx_aarch64.tar.gz";
      hash = "sha256-s40ircOZRX6AsN6jaeLKqeEpdizkp7pGfQfxnZ0DeYI=";
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
    hash = "sha256-2jftgy+Fs3XNaYkM71pxHHt1N1czgnb/JHbO8fYtHws=";
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
