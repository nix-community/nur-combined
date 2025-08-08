{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  php,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "upvote-rss";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "johnwarne";
    repo = "upvote-rss";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nYZjrgPb+9cNl6JjvW36w6FheXWSirCRV46tJ5N3NGg=";
  };

  nativeCheckInputs = [ php ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    php -l ./*.php ./**/*.php

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -R . $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Generate rich RSS feeds from Reddit, Hacker News, Lemmy, Mbin, and more";
    homepage = "https://github.com/johnwarne/upvote-rss";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
