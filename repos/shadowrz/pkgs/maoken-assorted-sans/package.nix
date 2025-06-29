{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "maoken-assorted-sans";
  version = "1.60";

  src = fetchurl {
    url = "https://github.com/Skr-ZERO/MaokenAssortedSans/releases/download/v${finalAttrs.version}/MaokenAssortedSans.ttf";
    sha256 = "sha256-gJeIbnQfcRKxDqHdVnAUMYZc7Oo2zxgTV73NwFRRMA0=";
  };

  dontUnpack = true;
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype/
    cp $src $out/share/fonts/truetype/MaokenAssortedSans.ttf
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Skr-ZERO/MaokenAssortedSans";
    description = "A Chinese font derived from Nishiki-teki";
    license = licenses.ofl;
    platforms = platforms.all;
  };
})
