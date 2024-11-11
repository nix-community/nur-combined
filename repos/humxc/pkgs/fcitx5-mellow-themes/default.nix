{ lib
, fetchFromGitHub
, stdenvNoCC
, themeName ? "youlan"
}:
let
  pname = "fcitx5-mellow-themes";
  version = "9694953eb1bd6c9363cf9c76833347bfa5ffd886";
  sha256 = "sha256-+wJOPUmUkR/uR9zdFyrV86D6nsYnC94zHXkEfjmAVjs=";
  src = fetchFromGitHub {
    owner = "sanweiya";
    repo = "fcitx5-mellow-themes";
    rev = version;
    sha256 = sha256;
  };
in
assert lib.elem themeName [ "youlan" "wechat" "vermilion" "sakura" "graphite" ];
stdenvNoCC.mkDerivation
{
  pname = pname;
  version = version;
  src = src;

  installPhase = ''
    mkdir -p $out
    cp -r $src/mellow-${themeName} $out/
    cp -r $src/mellow-${themeName}-dark $out/
  '';
  meta = with lib; {
    homepage = "https://github.com/sanweiya/fcitx5-mellow-themes";
    description = "Aesthetic, modern fcitx5 theme featuring rounded rectangle design.";
    license = licenses.bsd2;
  };
}
