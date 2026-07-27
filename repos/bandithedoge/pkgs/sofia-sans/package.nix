{
  sources,

  lib,
  stdenvNoCC,
  installFonts,
}:
stdenvNoCC.mkDerivation {
  inherit (sources.sofia-sans) pname src;
  version = sources.sofia-sans.date;

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Comprehensive type system in four widths with extended coverage of the Latin-, Greek- and Cyrillic Script";
    homepage = "https://github.com/lettersoup/Sofia-Sans";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
