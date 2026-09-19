{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  python3Packages,
  nix-update-script,
}:

let
  rev = "37d12e3eea75b804e55b83e2351fd1df9510c2b5";
  version = "0.1.0.dev+${rev}";

  hash        = "sha256-4Os95+SoprT+Y4RAvwCpPV69GNaroeqQ29R25cLYF30=";
  npmDepsHash = "sha256-8iqKWnBg32p7r+m6+n7h7rI5UB1Jyl9OZ2ulhxWmPmQ=";

  src = fetchFromGitHub {
    owner = "faraplay";
    repo = "zundamahjong";
    inherit rev hash;
  };

  zundamahjong-client = buildNpmPackage {
    pname = "zundamahjong-client";
    inherit version;

    src = "${src}/client";

    inherit npmDepsHash;
    npmPackFlags = [ "--ignore-scripts" ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r ../client_build/. $out

      runHook postInstall
    '';
  };
in

python3Packages.buildPythonApplication {
  pname = "zundamahjong";
  inherit version;
  pyproject = true;

  outputs = [
    "out"
    "doc"
  ];

  inherit src;

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
    sphinxHook
    sphinx-rtd-theme
  ];

  dependencies = with python3Packages; [
    flask
    flask-socketio
    pydantic
    sqlalchemy
    werkzeug
  ];

  preBuild = ''
    cp -r ${zundamahjong-client} client_build
    chmod -R u+w client_build
  '';

  passthru = {
    client = zundamahjong-client;

    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
        "--subpackage"
        "client"
      ];
    };
  };

  meta = {
    description = "Web-based mahjong game";
    homepage = "https://github.com/faraplay/zundamahjong";
    license = lib.licenses.mit;
  };
}
