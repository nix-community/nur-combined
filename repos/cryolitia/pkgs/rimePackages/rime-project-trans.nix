{ stdenvNoCC
, lib
, fetchurl
}:

stdenvNoCC.mkDerivation rec {

  pname = "rime-project-trans";
  version = "unstabl-20231114";

  src = fetchurl {
    url = "https://github.com/project-trans/rime-dict/releases/download/unstable-20231114/project_trans.dict.yaml";
    sha256 = "sha256-1vI5k3tH9pCGOnoVI30eyHRR06fqRC6BsgS+No6YeCE=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -pv $out/share/rime-data/
    cp ${src} $out/share/rime-data/project-trans.dict.yaml
  '';

  meta = with lib; {
    homepage = "https://github.com/project-trans/rime-dict";
    description = "Project Trans RIME Dict —— 跨儿计划 RIME 词典";
    maintainers = with maintainers; [ Cryolitia ];
  };
}
