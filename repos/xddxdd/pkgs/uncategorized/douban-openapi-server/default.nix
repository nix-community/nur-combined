{
  stdenv,
  lib,
  sources,
  makeWrapper,
  python3,
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
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.douban-openapi-server) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt

    cp -r * $out/opt/

    makeWrapper ${lib.getExe' pythonEnv "gunicorn"} $out/bin/douban-openapi-server \
      --add-flags "--chdir" \
      --add-flags "$out/opt/" \
      --append-flags "app:app"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Douban API server that provides an unofficial APIs for media information gathering";
    homepage = "https://github.com/caryyu/douban-openapi-server";
    license = with lib.licenses; [ mit ];
    broken = true;
  };
})
