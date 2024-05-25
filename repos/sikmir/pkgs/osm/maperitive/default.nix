{
  lib,
  stdenv,
  fetchurl,
  unzip,
  mono,
  gtk2,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maperitive";
  version = "2.4.3";

  src = fetchurl {
    url = "http://maperitive.net/download/Maperitive-${finalAttrs.version}.zip";
    hash = "sha256-yhslRj4CjUY0kviQTI7z8LvSiWvjf7K8+tDMeA9zNEk=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/opt/maperitive
    cp -r . $out/opt/maperitive

    makeWrapper ${mono}/bin/mono $out/bin/maperitive \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ gtk2 ]} \
      --run "[ -d \$HOME/.maperitive ] || { cp -r $out/opt/maperitive \$HOME/.maperitive && chmod -R +w \$HOME/.maperitive; }" \
      --add-flags "--desktop \$HOME/.maperitive/Maperitive.exe"
  '';

  meta = {
    description = "Desktop application for drawing maps based on OpenStreetMap and GPS data";
    homepage = "http://maperitive.net/";
    changelog = "http://maperitive.net/updates.xml";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = true;
  };
})
