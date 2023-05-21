{
  stdenvNoCC,
  lib,
  sources,
  unzip,
  ...
} @ args:
stdenvNoCC.mkDerivation rec {
  inherit (sources.hoyo-glyphs) pname version;

  srcs = [
    sources.hoyo-glyphs.src
    sources.hoyo-glyphs-star-rail-neue.src
  ];

  sourceRoot = ".";

  nativeBuildInputs = [unzip];

  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    find . -name \*.otf -exec cp {} $out/share/fonts/opentype/ \;
  '';

  meta = with lib; {
    description = "Constructed scripts by Hoyoverse 米哈游的架空文字 ";
    homepage = "https://github.com/SpeedyOrc-C/Hoyo-Glyphs";
  };
}
