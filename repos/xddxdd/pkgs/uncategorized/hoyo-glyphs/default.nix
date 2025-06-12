{
  stdenvNoCC,
  lib,
  sources,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.hoyo-glyphs) pname version src;

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/opentype/
    find . -name \*.otf -exec install -m644 {} $out/share/fonts/opentype/ \;

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/SpeedyOrc-C/Hoyo-Glyphs/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Constructed scripts by Hoyoverse 米哈游的架空文字";
    homepage = "https://github.com/SpeedyOrc-C/Hoyo-Glyphs";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
})
