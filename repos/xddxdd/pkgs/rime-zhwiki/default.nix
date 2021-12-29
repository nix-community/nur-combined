{ stdenv
, fetchurl
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "rime-zhwiki";
  version = "20211121";
  src = fetchurl {
    url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.3/zhwiki-${version}.dict.yaml";
    sha256 = "05by76l0nm3sj09xqbf7g7ic61r833cwnhjhn41cmvw5swr3vlpy";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/rime-data
    cp ${src} $out/share/rime-data/zhwiki.dict.yaml
  '';
}
