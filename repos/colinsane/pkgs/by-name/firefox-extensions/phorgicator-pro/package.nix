{
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation {
  pname = "phorgicator-pro";
  version = "0.1";
  src = ./.;

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  buildPhase = ''
    runHook preBuild
    zip -j firefox.zip \
      content.js manifest.json
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    install firefox.zip $out/$extid.xpi
    runHook postInstall
  '';

  extid = "@phorgicator-pro";
}
