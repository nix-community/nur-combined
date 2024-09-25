{
  stdenv,
  lib,
  sources,
  makeWrapper,
  python3,
  flasgger,
  ...
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      selenium
      flask
      greenlet
      eventlet
      gevent
      gunicorn
      flask-caching
      requests
      beautifulsoup4
      flask-restful
      flasgger
      flask-cors
    ]
  );
in
stdenv.mkDerivation rec {
  inherit (sources.douban-openapi-server) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt

    cp -r * $out/opt/

    makeWrapper ${pythonEnv}/bin/gunicorn $out/bin/douban-openapi-server \
      --add-flags "--chdir" \
      --add-flags "$out/opt/" \
      --append-flags "app:app"

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "A Douban API server that provides an unofficial APIs for media information gathering";
    homepage = "https://github.com/caryyu/douban-openapi-server";
    license = with licenses; [ mit ];
  };
}
