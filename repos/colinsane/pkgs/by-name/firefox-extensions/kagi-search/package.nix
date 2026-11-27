{
  fetchFromGitHub,
  gitUpdater,
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kagi-search";
  version = "0.7.8";
  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "browser_extensions";
    rev = "release/${finalAttrs.version}";
    hash = "sha256-dt+D7EjlX083rMteBKuzjrXmB1LdYVgjHfmmOVWpSpQ=";
  };

  # read `browser.storage.managed`, so that the session token can be provisioned
  # declaratively (e.g. via ~/.mozilla/managed-storage/search@kagi.com.json) instead of
  # by logging in interactively, which is impossible when cookies aren't persisted.
  patches = [ ./0001-read-managed-storage.patch ];

  buildPhase = ''
    # inline what `build.js` does
    cp -R shared/* firefox
    (cd firefox ; zip -r -FS ../firefox.xpi .)
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 firefox.xpi $out/$extid.xpi

    runHook postInstall
  '';

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  extid = "search@kagi.com";
  passthru.updateScript = gitUpdater {
    rev-prefix = "release/";
  };

  meta = {
    description = "A simple helper extension for setting Kagi as a default search engine, and automatically logging in to Kagi in incognito browsing windows.";
  };
})
