{
  lib,
  sources,
  stdenv,
  python3,
  makeWrapper,
  chromedriver,
  chromium,
  xorg,
  ...
}: let
  python = python3.withPackages (p:
    with p; [
      bottle
      waitress
      selenium
      func-timeout
      requests
      websockets
      xvfbwrapper
    ]);

  path = lib.makeBinPath [
    chromedriver
    chromium
    xorg.xorgserver
  ];
in
  stdenv.mkDerivation {
    inherit (sources.flaresolverr) pname version src;

    nativeBuildInputs = [makeWrapper];

    postPatch = ''
      substituteInPlace src/utils.py \
        --replace 'PATCHED_DRIVER_PATH = None' 'PATCHED_DRIVER_PATH = "${chromedriver}/bin/chromedriver"'
    '';

    installPhase = ''
      mkdir -p $out/bin $out/opt
      cp -r * $out/opt/

      makeWrapper ${python}/bin/python $out/bin/flaresolverr \
        --add-flags "$out/opt/src/flaresolverr.py" \
        --prefix PATH : "${path}"
    '';

    meta = with lib; {
      description = "Proxy server to bypass Cloudflare protection";
      homepage = "https://github.com/FlareSolverr/FlareSolverr";
      license = licenses.mit;
    };
  }
