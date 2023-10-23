{ maintainers
, stdenvNoCC
, lib
, fetchFromGitHub
}:
let

  version' = "0.2.1";

  src' = fetchFromGitHub {
    owner = "hosxy";
    repo = "Fcitx5-Material-Color";
    rev = "${version'}";
    sha256 = "sha256-i9JHIJ+cHLTBZUNzj9Ujl3LIdkCllTWpO1Ta4OT1LTc=";
  };

in stdenvNoCC.mkDerivation rec {

  pname = "fcitx5-material-color";
  version = version';

  dontUnpack = true;

  installPhase = ''
    mkdir Material-Color
    cp -rv ${src'}/* Material-Color/
    install -dDm644 Material-Color $out/share/fcitx5/themes/
  '';

  meta = with lib; {
    description = "一款使用Material Design 配色的 fcitx5 皮肤，喜欢的话给个 star 吧 ヾ(≧へ≦)〃 😉";
    homepage = "https://github.com/hosxy/Fcitx5-Material-Color";
    license = licenses.apsl20;
    maintainers = with maintainers; [ Cryolitia ];
  };
}