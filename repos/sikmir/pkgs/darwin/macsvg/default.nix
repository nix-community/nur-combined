{ lib, stdenv, fetchfromgh, unzip, makeWrapper }:

stdenv.mkDerivation (finalAttrs: {
  pname = "macsvg-bin";
  version = "1.2.0";

  src = fetchfromgh {
    owner = "dsward2";
    repo = "macSVG";
    name = "macSVG-v${lib.versions.majorMinor finalAttrs.version}.zip";
    hash = "sha256-wlEFUzFQ9fnSjmsIrCDzRvSZmfcK9V+go6pNYJOqN+w=";
    version = "v${finalAttrs.version}";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv macSVG_v${lib.replaceStrings [ "." ] [ "_" ] (lib.versions.majorMinor finalAttrs.version)}/*.app $out/Applications
    makeWrapper $out/{Applications/macSVG.app/Contents/MacOS/macSVG,bin/macsvg}
    runHook postInstall
  '';

  meta = with lib; {
    description = "An open-source macOS app for designing HTML5 SVG";
    homepage = "https://macsvg.org/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    mainProgram = "macsvg";
    skip.ci = true;
  };
})
