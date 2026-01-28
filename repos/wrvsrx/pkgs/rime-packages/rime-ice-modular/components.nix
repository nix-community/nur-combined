{ rime-ice-modular-src, callPackage }:
let
  prefix = "rime-ice-";
  components = builtins.fromJSON (builtins.readFile ./components.json);
  components' = builtins.listToAttrs (
    map (x: {
      name = prefix + x;
      value =
        let
          src = callPackage (
            { stdenv }:
            stdenv.mkDerivation {
              name = prefix + x + "-src";
              src = rime-ice-modular-src;
              buildPhase = "true";
              installPhase = ''
                ${builtins.concatStringsSep "\n" (
                  map (y: ''
                    install -D --mode=644 ${rime-ice-modular-src}/${y} $out/${y}
                  '') components.${x}.outputs
                )}
              '';
            }
          ) { };
        in
        callPackage (
          {
            rimeDataBuildHook,
            rime-prelude,
            librime,
            stdenv,
          }:
          stdenv.mkDerivation {
            pname = prefix + x;
            inherit (rime-ice-modular-src) version;
            inherit src;
            propagatedBuildInputs = (map (y: components'.${prefix + y}) components.${x}.dependencies) ++ [
              rime-prelude
            ];
            nativeBuildInputs = [
              rimeDataBuildHook
              librime
            ];
            installPhase = ''
              rm -rf rime_data_deps/
              mkdir -p $out/share/rime-data/
              cp -r . $out/share/rime-data/
            '';
          }
        ) { };
    }) (builtins.attrNames components)
  );
in
{
  inherit (components')
    rime-ice-pinyin
    rime-ice-double-pinyin
    rime-ice-double-pinyin-flypy
    rime-ice-double-pinyin-abc
    rime-ice-double-pinyin-mspy
    rime-ice-double-pinyin-sogou
    rime-ice-double-pinyin-ziguang
    ;
}
