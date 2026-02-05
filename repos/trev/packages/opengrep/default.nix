{
  autoPatchelfHook,
  fetchFromGitHub,
  fetchurl,
  lib,
  nix-update-script,
  python3Packages,
  stdenv,
}:
let
  pname = "opengrep";
  version = "1.16.0";

  binaries = {
    aarch64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_aarch64.tar.gz";
      hash = "sha256-5qkuLEZbUyhK4ybSCzFay9LrmbyepLOvSNtjeTBvOoI=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_linux_x86.tar.gz";
      hash = "sha256-TUdBQTKZg8Td16bNWGdZ3uzH8/qa7m5u6rjFV1ncgWs=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/opengrep/opengrep/releases/download/v${version}/opengrep-core_osx_aarch64.tar.gz";
      hash = "sha256-s9b/hjRJAUhEOR7muHQGg1JHh9pasHl/mPqjJxTlWOk=";
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
python3Packages.buildPythonApplication {
  inherit core pname version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "opengrep";
    repo = "opengrep";
    tag = "v${version}";
    hash = "sha256-oAnjpiFt+Irch+Xtookd7c3iLb24Ufck3H3naLLn4jY=";
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
