{ lib, stdenvNoCC, fetchurl }:

let
  dicts = lib.mapAttrs
    (name: spec:
      fetchurl {
        url = "http://libredict.org/dictionaries/${name}/wiktionary_${name}_stardict_${spec.version}.tgz";
        inherit (spec) hash;
      }
    )
    (lib.importJSON ./dicts.json);
in
stdenvNoCC.mkDerivation {
  pname = "libredict";
  version = "2023-05-20";

  srcs = lib.attrValues dicts;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    mv Wiktionary* $out
  '';

  meta = with lib; {
    description = "Wiktionary dictionaries for StarDict";
    homepage = "http://libredict.org";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
