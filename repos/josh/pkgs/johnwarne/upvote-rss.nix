{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  php,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "upvote-rss";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "johnwarne";
    repo = "upvote-rss";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8YaUQiqp6D2LNrjqp5lWyzPy2FvPwc8t4AC/YjnDl5A=";
  };

  postPatch = ''
    substituteInPlace config.php \
      --replace-fail "const UPVOTE_RSS_CACHE_ROOT         = __DIR__ . '/cache/';" \
                     'define("UPVOTE_RSS_CACHE_ROOT", ($_SERVER["CACHE_DIRECTORY"] ?? $_ENV["CACHE_DIRECTORY"] ?? sys_get_temp_dir() . "/upvote-rss") . "/cache/");'
    substituteInPlace classes/custom-logger.php \
      --replace-fail "__DIR__ . '/../logs/upvote-rss.log'" 'UPVOTE_RSS_CACHE_ROOT . "../logs/upvote-rss.log"'
    grep -qF "CACHE_DIRECTORY" config.php
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
    cp *.php favicon.ico $out/
    cp -R classes inc views vendor js styles img $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests =
    let
      upvote-rss = finalAttrs.finalPackage;
    in
    {
      index = runCommand "upvote-rss-index" { nativeBuildInputs = [ php ]; } ''
        export CACHE_DIRECTORY="$TMPDIR/upvote-rss"
        mkdir -p "$CACHE_DIRECTORY"

        export http_proxy="http://127.0.0.1:1"
        export https_proxy="http://127.0.0.1:1"

        pushd ${upvote-rss}/
        export HTTP_HOST="localhost"
        export REQUEST_URI="/"
        php -f index.php >"$CACHE_DIRECTORY/output.html"
        popd

        grep -q "<!DOCTYPE html>" "$CACHE_DIRECTORY/output.html"
        touch $out
      '';
    };

  meta = {
    description = "Generate rich RSS feeds from Reddit, Hacker News, Lemmy, Mbin, and more";
    homepage = "https://github.com/johnwarne/upvote-rss";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
