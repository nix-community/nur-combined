{ stdenv
, sources
, lib
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.rime-moegirl) pname version src;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/rime-data
    cp ${src} $out/share/rime-data/moegirl.dict.yaml
  '';

  meta = with lib; {
    description = "Releases for dict of zh.moegirl.org.cn";
    homepage = "https://github.com/outloudvi/mw2fcitx/releases";
    license = licenses.unlicense;
  };
}
