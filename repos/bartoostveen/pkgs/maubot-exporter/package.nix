{
  lib,
  fetchFromForgejo,
  nix-update-script,
  python314Packages,
  stdenv,
  makeWrapper,
}:

stdenv.mkDerivation (_finalAttrs: {
  pname = "maubot-exporter";
  version = "0-unstable-2026-06-02";

  pyproject = false;

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.kurocon.nl";
    owner = "kuronet";
    repo = "maubot-exporter";
    rev = "72125b8dc8328ca837014669f88b788c89a5b1d8";
    hash = "sha256-l5v9pEPJf/oChVqM/WwVLoVWia4xqFs4JYIoB51DJvE=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase =
    let
      pythonEnv = python314Packages.python.withPackages (
        ps: with ps; [
          flask
          gunicorn
          requests
          prometheus-client
        ]
      );
    in
    ''
      mkdir -p $out/libexec
      cp exporter.py $out/libexec/

      makeWrapper ${lib.getExe' pythonEnv "gunicorn"} $out/bin/maubot-exporter \
        --add-flags "--chdir $out/libexec exporter:app"
    '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

  meta = {
    description = "Simple metrics exporter for maubot";
    homepage = "https://git.kurocon.nl/kuronet/maubot-exporter";
    license = [ ];
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "maubot-exporter";
    platforms = lib.platforms.all;
  };
})
