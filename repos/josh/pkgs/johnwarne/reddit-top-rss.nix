{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  runCommand,
  nix-update-script,
  php,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "reddit-top-rss";
  version = "0-unstable-2025-02-10";

  src = fetchFromGitHub {
    owner = "johnwarne";
    repo = "reddit-top-rss";
    rev = "5e38bfd2e6718a42a579ad53800413cee20a4c22";
    hash = "sha256-0G9pRgkoAPFJh2W0TmARGSmdOTfIovtVP+MRAaxSFm4=";
  };

  extraConfig = ''

    if (!empty($_SERVER["CACHE_DIRECTORY"])) {
      define('CACHE_DIRECTORY', $_SERVER["CACHE_DIRECTORY"]);
    } else {
      define('CACHE_DIRECTORY', sys_get_temp_dir() . '/reddit-top-rss');
    }
  '';

  postPatch = ''
    substituteInPlace *.php --replace-warn '"cache/' 'CACHE_DIRECTORY . "/'
    substituteInPlace *.php --replace-warn "'cache/" "CACHE_DIRECTORY . '/"
  '';

  nativeCheckInputs = [ php ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    php -l *.php

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp *.php $out/
    cp config-default.php $out/config.php
    echo "$extraConfig" >>$out/config.php
    cp -R dist $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests =
    let
      reddit-top-rss = finalAttrs.finalPackage;
    in
    {
      index = runCommand "reddit-top-rss-index" { nativeBuildInputs = [ php ]; } ''
        export CACHE_DIRECTORY="$TMPDIR/reddit-top-rss"
        mkdir -p "$CACHE_DIRECTORY"

        pushd ${reddit-top-rss}/
        export HTTP_HOST="localhost"
        export REQUEST_URI="/"
        php -f index.php | tee "$CACHE_DIRECTORY/output.html"
        popd

        grep "<!DOCTYPE html>" "$CACHE_DIRECTORY/output.html"
        [ -f "$CACHE_DIRECTORY/token/token.txt" ]
        touch $out
      '';
    };

  meta = {
    description = "Generate RSS feeds for specified subreddits with score thresholds";
    homepage = "https://github.com/johnwarne/reddit-top-rss";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
