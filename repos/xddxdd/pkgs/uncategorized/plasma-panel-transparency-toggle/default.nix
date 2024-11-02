{
  lib,
  sources,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.plasma-panel-transparency-toggle) pname version src;

  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids/org.kde.panel.transparency.toggle
    cp -r * $out/share/plasma/plasmoids/org.kde.panel.transparency.toggle
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Rewrite of [Panel Transparency Button](https://github.com/psifidotos/paneltransparencybutton) for plasma 6";
    homepage = "https://github.com/sanjay-kr-commit/panelTransparencyToggleForPlasma6";
    license = licenses.gpl2Only;
  };
}
