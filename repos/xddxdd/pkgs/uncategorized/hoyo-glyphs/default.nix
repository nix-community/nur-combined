{
  stdenvNoCC,
  lib,
  sources,
  unzip,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.hoyo-glyphs) pname version;

  srcs = [
    sources.hoyo-glyphs.src
    sources.hoyo-glyphs-star-rail-neue.src
    sources.hoyo-glyphs-teyvat-black.src
    sources.hoyo-glyphs-xianzhou-seal.src
    sources.hoyo-glyphs-font-ainee.src
    sources.hoyo-glyphs-zzz-a.src
    sources.hoyo-glyphs-zzz-system.src
  ];

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    find . -name \*.otf -exec install -m644 {} $out/share/fonts/opentype/ \;
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Constructed scripts by Hoyoverse 米哈游的架空文字 ";
    homepage = "https://github.com/SpeedyOrc-C/Hoyo-Glyphs";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
}
