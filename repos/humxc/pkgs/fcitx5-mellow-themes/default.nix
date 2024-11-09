{ lib
, fetchFromGitHub
, stdenvNoCC
, themeName ? "youlan"
, themeIsDark ? false
}:
let
  pname = "fcitx5-mellow-themes";
  version = "1154bdb28d21b6f7a6b67311cc4f831fc75a651b";
  sha256 = "sha256-dxKMOfS9slGcllCmTZ0HGJbKC+4E+WFFd5Y44XD2AKk=";
  src = fetchFromGitHub {
    owner = "sanweiya";
    repo = "fcitx5-mellow-themes";
    rev = version;
    sha256 = sha256;
  };
  getDir = name: isDark: "mellow-${name}${if isDark then "-dark" else ""}";
in
assert lib.elem themeName [ "youlan" "wechat" "vermilion" "sakura" "graphite" ];
stdenvNoCC.mkDerivation
{
  pname = pname;
  version = version;
  src = src;

  installPhase = ''
    mkdir -p $out
    cp ${getDir themeName themeIsDark}/* $out
  '';
  meta = with lib; {
    homepage = "https://github.com/sanweiya/fcitx5-mellow-themes";
    description = "Aesthetic, modern fcitx5 theme featuring rounded rectangle design.";
    license = licenses.bsd2;
  };
}
