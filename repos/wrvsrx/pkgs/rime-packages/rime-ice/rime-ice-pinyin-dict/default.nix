
{
  stdenvNoCC,
  haskellPackages,
  rimeDataBuildHook,
  librime,
  # we need default.yaml provided by rime-prelude
  rime-prelude,
  source,
  rime-ice-cn_dicts
}:
let
  src_ =
    stdenvNoCC.mkDerivation {
      inherit (source) src;
      version = "0-unstable-" + source.date;
      pname = "rime-ice-pinyin-dict";
      propagatedBuildInputs = [ rime-prelude rime-ice-cn_dicts ];
      nativeBuildInputs = [
        (haskellPackages.ghcWithPackages (
          ps: with ps; [
            shake
            yaml
            utf8-string
            raw-strings-qq
          ]
        ))
      ];
      env.LC_CTYPE = "C.UTF-8";
      postPatch = ''
        cp ${../Shakefile.hs} Shakefile.hs
      '';
      buildPhase = ''
        shake pinyin-dict
      '';
      installPhase = ''
        mkdir -p $out/share/rime-data
        mkdir -p build
        cp -r build/. $out/share/rime-data/
      '';
    };
in
  stdenvNoCC.mkDerivation {
    inherit (src_)
      pname
      version
      propagatedBuildInputs;
    src = "${src_}/share/rime-data";
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
