{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
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
  pname = "douban-openapi-server";
  version = "0-unstable-2022-12-17";
  src = fetchFromGitHub {
    owner = "caryyu";
    repo = "douban-openapi-server";
    rev = "c7e2a0f59ba5cfb2d10a31013547686a4afab99d";
    hash = "sha256-Ri56XBkGjLF8+Rv7lYDM83WfZ2rzwF0p5SZzBeC3ToI=";
  };
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Douban API server that provides unofficial APIs for media information gathering";
    homepage = "https://github.com/caryyu/douban-openapi-server";
    license = with lib.licenses; [ mit ];
    broken = true;
  };
})
