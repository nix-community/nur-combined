{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  dicts = lib.mapAttrs (
    name: spec:
    fetchurl {
      url = "http://libredict.org/dictionaries/${name}/wiktionary_${name}_stardict_${spec.version}.tgz";
      inherit (spec) hash;
    }
  ) (lib.importJSON ./dicts.json);
in
stdenvNoCC.mkDerivation {
  pname = "libredict";
  version = "2025-09-07";

  srcs = lib.attrValues dicts;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    mv Wiktionary* $out
  '';

  meta = {
    description = "Wiktionary dictionaries for StarDict";
    homepage = "http://libredict.org";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
