{
  stdenvNoCC,
  lib,
  sources,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.hi3-ii-martian-font) pname version src;

  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    find . -name \*.otf -exec install -m644 {} $out/share/fonts/opentype/ \;
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Font for Martian in Honkai Impact 3rd";
    homepage = "https://github.com/Wenti-D/HI3IIMartianFont";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
}
