{ lib, stdenv, fetchfromgh, unzip }:

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

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r macSVG_v${lib.replaceStrings [ "." ] [ "_" ] (lib.versions.majorMinor finalAttrs.version)}/*.app $out/Applications
  '';

  meta = with lib; {
    description = "An open-source macOS app for designing HTML5 SVG";
    homepage = "https://macsvg.org/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    skip.ci = true;
  };
})
