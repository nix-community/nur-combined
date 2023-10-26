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
    install -Dm644 arrow.png radio.png -t $out/share/${pname}/
    for _variant in black blue brown deepPurple indigo orange pink red sakuraPink teal; do
      _variant_name=Material-Color-$_variant
      install -dm755 $_variant_name $out/share/fcitx5/themes/$_variant_name
      ln -sv ../../../$pname/arrow.png $out/share/fcitx5/themes/$_variant_name/
      ln -sv ../../../$pname/radio.png $out/share/fcitx5/themes/$_variant_name/
      install -Dm644 theme-$_variant.conf $out/share/fcitx5/themes/$_variant_name/theme.conf
      sed -i "s/^Name=.*/Name=$_variant_name/" $out/share/fcitx5/themes/$_variant_name/theme.conf
    done
  '';

  meta = with lib; {
    description = "一款使用Material Design 配色的 fcitx5 皮肤，喜欢的话给个 star 吧 ヾ(≧へ≦)〃 😉";
    homepage = "https://github.com/hosxy/Fcitx5-Material-Color";
    license = licenses.apsl20;
    maintainers = with maintainers; [ Cryolitia ];
  };
}