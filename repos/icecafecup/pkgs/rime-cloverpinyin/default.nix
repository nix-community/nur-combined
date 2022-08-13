{ stdenv, lib, fetchurl, unzip, rime-data, ... }:

stdenv.mkDerivation rec {
  pname = "rime-cloverpinyin";
  version = "1.1.4";
  src = fetchurl {
    url = "https://github.com/fkxxyz/rime-cloverpinyin/releases/download/${version}/clover.schema-build-${version}.zip";
    sha256 = "sha256-jxgRqBlMnkWJlUyEYp/86S0FHZWjfedGwMBU/yROUeo=";
  };

  buildInputs = [ rime-data ];
  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    	unzip $src
  '';

  installPhase = ''
    mkdir -p $out/share/rime-data
    cp -r * $out/share/rime-data/
  '';

  meta = with lib; {
    description = "Clover Simplified pinyin input for Rime";
    homepage = "https://www.fkxxyz.com/d/cloverpinyin/";
    changelog = "https://github.com/fkxxyz/rime-cloverpinyin/releases/tag/${version}";
    license = licenses.lgpl3;
    platforms = platforms.all;
  };
}
