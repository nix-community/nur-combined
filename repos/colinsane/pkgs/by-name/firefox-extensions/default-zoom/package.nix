# inlined/simplified version of <https://github.com/jamielinux/default-zoom>
{
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation {
  pname = "default-zoom";
  version = "0.1";
  src = ./.;

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  buildPhase = ''
    runHook preBuild
    zip -j firefox.zip \
      background.html background.js manifest.json
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    install firefox.zip $out/$extid.xpi
    runHook postInstall
  '';

  extid = "default-zoom@uninsane.org";
}
