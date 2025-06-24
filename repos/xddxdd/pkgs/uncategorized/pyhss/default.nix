{
  lib,
  sources,
  stdenv,
  python3,
  makeWrapper,
  curl,
}:
let
  python = python3.withPackages (
    p: with p; [
      aiohttp
      comp128
      flask
      flask-restx
      influxdb
      jinja2
      mysqlclient
      prometheus-client
      (prometheus-flask-exporter.overridePythonAttrs (old: {
        doCheck = false;
      }))
      psycopg2
      pycryptodome
      pydantic
      pydantic-core
      pymongo
      pyosmocom
      pysctp
      pysnmp
      pyyaml
      redis
      requests
      sqlalchemy
      sqlalchemy-utils
      tzlocal
      werkzeug
      xmltodict
    ]
  );
in
stdenv.mkDerivation {
  inherit (sources.pyhss) pname version src;

  nativeBuildInputs = [
    makeWrapper
    curl
  ];

  postPatch = ''
    for F in $(find . -name \*.py); do
      substituteInPlace "$F" \
        --replace-quiet "../config.yaml" "config.yaml"
    done
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r * $out/opt/

    for F in $out/opt/services/*.py; do
      EXE_NAME=$(basename "$F")
      EXE_NAME=''${EXE_NAME%.py}
      makeWrapper ${python}/bin/python "$out/bin/$EXE_NAME" \
        --prefix PYTHONPATH : "$out/opt/lib" \
        --add-flags "$F"
    done

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python HSS / Diameter Server";
    homepage = "https://github.com/nickvsnetworking/pyhss";
    license = lib.licenses.agpl3Only;
  };
}
