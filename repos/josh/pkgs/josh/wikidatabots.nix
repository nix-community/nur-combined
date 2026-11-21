{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nur,

  makeWrapper,
  python3,

  nix-update-script,
  runCommand,
}:
let
  pythonEnv = python3.withPackages (ps: [
    ps.backoff
    ps.feedparser
    ps.requests
    ps.tqdm
    nur.repos.josh.polars
    nur.repos.josh.wikidata-rdf-patch
  ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "wikidatabots";
  version = "0-unstable-2026-11-21";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "wikidatabots";
    rev = "7d2acfd0c307b10dce5827c06295e69315597648";
    hash = "sha256-o1LFsCeNqAZmbDu0QOvk6jIf4ypjeOzf3sj6w+YHT60=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/wikidatabots
    for f in *.py; do
      case "$f" in
        test_*) ;;
        *) install -m644 "$f" $out/share/wikidatabots/ ;;
      esac
    done

    for script in wikidata_maxlag wd_tmdb wd_opencritic; do
      makeWrapper ${lib.getExe pythonEnv} $out/bin/''${script//_/-} \
        --add-flags $out/share/wikidatabots/$script.py
    done

    ln -s ${pythonEnv}/bin/wikidata-rdf-patch $out/bin/wikidata-rdf-patch

    runHook postInstall
  '';

  passthru.python = pythonEnv;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    imports = runCommand "test-wikidatabots-imports" { } ''
      ${lib.getExe pythonEnv} -c '
      import sys
      sys.path.insert(0, "${finalAttrs.finalPackage}/share/wikidatabots")
      import polars_requests, sparql, wd_opencritic, wd_tmdb, wikidata, wikidata_maxlag
      '
      touch $out
    '';
  };

  meta = {
    description = "Wikidata bots running under Josh404Bot";
    homepage = "https://github.com/josh/wikidatabots";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
