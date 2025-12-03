{
  fetchFromGitHub,
  gitUpdater,
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "kagi-search";
  version = "0.7.4";
  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "browser_extensions";
    rev = "release/${version}";
    hash = "sha256-OaydcKtrMgxMJMPpl6e2YXhm1FyqJPPpAMObEU45J84=";
  };

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
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "A simple helper extension for setting Kagi as a default search engine, and automatically logging in to Kagi in incognito browsing windows.";
  };
}
