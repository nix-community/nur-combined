{
  lib,
  fetchurl,
  p7zip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "resource-han-rounded";
  version = "0.990";

  src = fetchurl {
    url = "https://github.com/CyanoHao/Resource-Han-Rounded/releases/download/v${finalAttrs.version}/RHR-TTF-${finalAttrs.version}.7z";
    sha256 = "sha256-e/9vZtrxUB6OynP7NH2Z3vrHcdh2qr5ds1UsAKDQ2Gw=";
  };

  nativeBuildInputs = [ p7zip ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/truetype/ *.ttf
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/CyanoHao/Resource-Han-Rounded";
    description = "A rounded font family derived from Source Han Sans";
    license = licenses.ofl;
    platforms = platforms.all;
  };
})
