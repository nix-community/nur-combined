{
  sources,
  stdenvNoCC,
  lib,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.fcitx5-breeze) pname version src;

  installPhase = ''
    mkdir $out
    ./install.sh $out
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fcitx5 theme to match KDE's Breeze style";
    homepage = "https://github.com/scratch-er/fcitx5-breeze";
    license = licenses.gpl3Only;
  };
}
