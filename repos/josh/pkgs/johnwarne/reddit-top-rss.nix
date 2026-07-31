{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  php,
  nix-update-script,
  runCommand,
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

  postPatch = ''
    substituteInPlace *.php --replace-quiet '"cache/' 'CACHE_DIRECTORY . "/'
    substituteInPlace *.php --replace-quiet "'cache/" "CACHE_DIRECTORY . '/"
    substituteInPlace *.php --replace-quiet 'directorySize("cache")' 'directorySize(CACHE_DIRECTORY)'
    grep -qF 'CACHE_DIRECTORY . ' -- *.php
    grep -qF 'directorySize(CACHE_DIRECTORY)' -- *.php
    status=0
    grep -qF "'cache/" -- *.php || status=$?
    test "$status" -eq 1
    status=0
    grep -qF '"cache/' -- *.php || status=$?
    test "$status" -eq 1
    status=0
    grep -qF '"cache"' -- *.php || status=$?
    test "$status" -eq 1
  '';

  extraConfig = ''

    if (!empty($_SERVER["CACHE_DIRECTORY"])) {
      define('CACHE_DIRECTORY', $_SERVER["CACHE_DIRECTORY"]);
    } else {
      define('CACHE_DIRECTORY', sys_get_temp_dir() . '/reddit-top-rss');
    }
  '';

  nativeCheckInputs = [ php ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    find . -name '*.php' -print0 | xargs -0 -n1 php -l

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

        export http_proxy="http://127.0.0.1:1"
        export https_proxy="http://127.0.0.1:1"

        pushd ${reddit-top-rss}/
        export HTTP_HOST="localhost"
        export REQUEST_URI="/"
        php -f index.php >"$CACHE_DIRECTORY/output.html"
        popd

        grep -q "<!DOCTYPE html>" "$CACHE_DIRECTORY/output.html"
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
