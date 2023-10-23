{ maintainers
, stdenvNoCC
, lib
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation rec {

  pname = "fcitx5-material-color";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "hosxy";
    repo = "Fcitx5-Material-Color";
    rev = "${version}";
    sha256 = "sha256-i9JHIJ+cHLTBZUNzj9Ujl3LIdkCllTWpO1Ta4OT1LTc=";
  };

  installPhase = ''
    mkdir -pv $out/share/fcitx5/themes/Material-Color/
    cp -rv ${src}/* $out/share/fcitx5/themes/Material-Color/
  '';

  meta = with lib; {
    description = "一款使用Material Design 配色的 fcitx5 皮肤，喜欢的话给个 star 吧 ヾ(≧へ≦)〃 😉";
    homepage = "https://github.com/hosxy/Fcitx5-Material-Color";
    license = licenses.apsl20;
    maintainers = with maintainers; [ Cryolitia ];
  };
}