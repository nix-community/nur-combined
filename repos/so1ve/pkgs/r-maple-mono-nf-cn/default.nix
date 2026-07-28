{
  lib,
  source,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "r-maple-mono-nf-cn";
  inherit (source) version src;

  nativeBuildInputs = [ unzip ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/fonts/truetype"
    unzip -q -j "$src" '*.ttf' -d "$out/share/fonts/truetype"

    runHook postInstall
  '';

  meta = {
    description = "R Maple Mono with Nerd Font icons and CJK glyphs";
    homepage = "https://github.com/so1ve/maple-font";
    changelog = "https://github.com/so1ve/maple-font/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
