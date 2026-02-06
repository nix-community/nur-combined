{
  pkgs,
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  libsForQt5,
  themeConfig ? null,
}:
stdenvNoCC.mkDerivation rec {
  name = "sddm-eucalyptus-drop";
  version = "2.0.0";
  src = fetchFromGitLab {
    owner = "Matt.Jolly";
    repo = "sddm-eucalyptus-drop";
    tag = "v${version}";
    hash = "sha256-wq6V3UOHteT6CsHyc7+KqclRMgyDXjajcQrX/y+rkA0=";
  };
  buildInputs = [
    libsForQt5.qt5.qtgraphicaleffects
  ];
  dontWrapQtApps = true;
  installPhase =
    let
      iniFormat = pkgs.formats.ini { };
      basePath = "$out/share/sddm/themes/eucalyptus-drop";
      configFile = iniFormat.generate "" {
        General = themeConfig;
      };
    in
    ''
      runHook preInstall
      mkdir -p ${basePath}
      mv * ${basePath}
      ${
        lib.optionalString (themeConfig != null) ''
          ln -sf ${configFile} ${basePath}/theme.conf.user
        ''
      } 
      runHook postInstall
    '';
  meta = {
    description = "An enhanced fork of SDDM Sugar Candy by Marian Arlt";
    homepage = "https://gitlab.com/Matt.Jolly/sddm-eucalyptus-drop/";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
