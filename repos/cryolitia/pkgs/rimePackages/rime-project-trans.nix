{ stdenvNoCC
, lib
, fetchurl
}:

let 

  dict = fetchurl {
    url = "https://github.com/project-trans/rime-dict/releases/download/unstable-20231115/project_trans.dict.yaml";
    sha256 = "sha256-YG3xB/Ip3ZQ+Y6sqb4yD/rQDsRqQUWdiA8bH6FmC84E=";
  };

  dict_pinyin = fetchurl {
    url = "https://github.com/project-trans/rime-dict/releases/download/unstable-20231115/project_trans_pinyin.dict.yaml";
    sha256 = "sha256-YTSM+wXDrHiJfwh3eLeUmHvTotIJzEmk7uPHUqYIMlE=";
  };

in stdenvNoCC.mkDerivation {

  pname = "rime-project-trans";
  version = "unstable-20231115";

  dontUnpack = true;

  installPhase = ''
    mkdir -pv $out/share/rime-data/
    cp -v ${dict} $out/share/rime-data/project_trans.dict.yaml
    cp -v ${dict_pinyin} $out/share/rime-data/project_trans_pinyin.dict.yaml
  '';

  meta = with lib; {
    homepage = "https://github.com/project-trans/rime-dict";
    description = "Project Trans RIME Dict —— 跨儿计划 RIME 词典";
    maintainers = with maintainers; [ Cryolitia ];
  };
}
