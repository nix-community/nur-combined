{ lib
, stdenvNoCC
, fetchFromGitHub
, fetchurl
, python3Packages
, libime
}:

stdenvNoCC.mkDerivation {
  pname = "fcitx5-pinyin-chinese-idiom";
  version = "20190117";

  srcs = [
    (fetchurl {
      name = "idiom.json";
      url = "https://raw.githubusercontent.com/pwxcoo/chinese-xinhua/master/data/idiom.json";
      hash = "sha256-HUtPRUzhxBbWoasjadbmbA/5ngQ5AXLu9weQSZ4hzhk=";
    })
    (fetchurl {
      name = "convert.py";
      url = "https://raw.githubusercontent.com/Kienyew/fcitx5-pinyin-chinese-idiom/master/convert.py";
      hash = "sha256-QD7ClItF/yEyOuSjU3Et7SJDJlTV21KlkX9OxpF64mQ=";
    })
  ];

  unpackPhase = ''
    cp $srcs ./
  '';

  nativeBuildInputs = [
    (with python3Packages; python.buildEnv.override {
      extraLibs = [ pypinyin ];
    })
    libime
  ];

  buildPhase = ''
    python3 *-convert.py *-idiom.json > idiom.raw
    libime_pinyindict idiom.raw idiom.dict
  '';

  installPhase = ''
    install -Dm644 idiom.dict \
      $out/share/fcitx5/pinyin/dictionaries/fcitx5-pinyin-chinese-idiom.dict
  '';

  meta = with lib; {
    description = "A dictionary of chinese idioms for fcitx5 pinyin from Xinhua dictionary (no auto update)";
    homepage = "https://github.com/Kienyew/fcitx5-pinyin-chinese-idiom";
    license = licenses.mit;
  };
}
