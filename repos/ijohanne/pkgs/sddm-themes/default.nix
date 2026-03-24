{ sources, mkDerivation, qtbase, qtquickcontrols, qtgraphicaleffects }:
{
  sddm-sugar-dark = mkDerivation rec {
    pname = "sddm-sugar-dark-theme";
    version = "1.2";
    dontBuild = true;
    buildInputs = [ qtbase qtquickcontrols qtgraphicaleffects ];
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/sugar-dark
    '';
    src = sources.sddm-sugar-dark;
  };
  sddm-chili = mkDerivation rec {
    pname = "sddm-sugar-chili-theme";
    version = "1.2";
    dontBuild = true;
    buildInputs = [ qtbase qtquickcontrols qtgraphicaleffects ];
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/chili
    '';
    src = sources.sddm-chili;
  };

}
