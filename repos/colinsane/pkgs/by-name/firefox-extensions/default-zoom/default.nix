# inlined/simplified version of <https://github.com/jamielinux/default-zoom>
{
  stdenvNoCC,
  zip,
}:
stdenvNoCC.mkDerivation {
  pname = "default-zoom";
  version = "0.1";
  src = ./.;

  nativeBuildInputs = [ zip ];

  buildPhase = ''
    runHook preBuild
    zip -j firefox.zip \
      background.html background.js manifest.json
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install firefox.zip $out
    runHook postInstall
  '';

  passthru.extid = "@default-zoom";
}
