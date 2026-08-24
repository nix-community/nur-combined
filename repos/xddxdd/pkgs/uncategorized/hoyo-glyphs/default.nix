{
  fetchurl,
  nix-update-script,
  stdenv,
  lib,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hoyo-glyphs";
  version = "20250529";
  src = fetchurl {
    url = "https://github.com/SpeedyOrc-C/HoYo-Glyphs/releases/download/20250529/HoYo-Glyphs-20250529.zip";
    hash = "sha256-MT+RrgsC2Y1EWFNdBuVyy23hAnHOy0TvARxl4Zy6A6k=";
  };
  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/opentype/
    find . -name \*.otf -exec install -m644 {} $out/share/fonts/opentype/ \;

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/SpeedyOrc-C/Hoyo-Glyphs/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Constructed scripts by Hoyoverse 米哈游的架空文字";
    homepage = "https://github.com/SpeedyOrc-C/Hoyo-Glyphs";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
})
