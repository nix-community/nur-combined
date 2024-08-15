{ lib
, buildNpmPackage
, fetchFromGitHub
, python3
, beets
}:

let
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "sentriz";
    repo = "betanin";
    rev = "v${version}";
    hash = "sha256-8JzZfxXzey6vGwsnpXTea/gTMFwmeeavimn5njHIEg0=";
  };

  client = buildNpmPackage {
    pname = "betanin_client";
    inherit version src;

    sourceRoot = "${src.name}/betanin_client";

    npmDepsHash = "sha256-VkCQKpkDCTDejv8eRAN2Zfbq8TlWLdtqVJU3fo9hQrI=";
    NODE_ENV = "production";
    NODE_OPTIONS = "--openssl-legacy-provider";

    npmInstallFlags = [ "--include=dev" ];
    installPhase = ''
      cp -r dist $out
    '';
  };
in
python3.pkgs.buildPythonApplication {
  pname = "betanin";
  inherit version src;
  format = "pyproject";

  patches = [ ./paths.patch ];
  postPatch = ''
    export clientDistDir="${client}"
    export libPrefix="${python3.libPrefix}"
    substituteAllInPlace betanin/paths.py

    # pythonRelaxDepsHook doesn't work
    sed -i 's/Flask <3.0.0/Flask/' pyproject.toml
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = (with python3.pkgs; [
    apprise
    alembic
    click
    flask
    flask-cors
    flask-jwt-extended
    flask_migrate
    flask-restx
    flask-socketio
    flask-sqlalchemy
    gevent
    pyxdg
    loguru
    ptyprocess
    python-engineio
    python-socketio
    sqlalchemy
    sqlalchemy-utils
    toml
  ]) ++ [
    beets
  ];

  meta = {
    homepage = "https://github.com/sentriz/betanin";
    description = "beets based mitm of your torrent client and music player";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
