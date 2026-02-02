{
  lib,
  pkgs,
  stdenvNoCC,
  fetchFromGitHub,
  themeConfig ? { },
  fixPath ? true,
}:
let
  cfg = {
    theme = "forest";
    type = "window";
    side = "left";
    color = "dark";
    screen = "1080p";
    logo = "default";
    background = null;
  }
  // themeConfig;
  isValid = import ./isValid.nix;
in
if isValid cfg then
  with cfg;
  let
    nativeBuildInputs = if builtins.isNull background then [ ] else [ pkgs.imagemagick ];
  in
  stdenvNoCC.mkDerivation rec {
    inherit nativeBuildInputs;
    name = "Elegant-grub2-themes";
    version = "2025-03-25";
    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = name;
      tag = version;
      hash = "sha256-M9k6R/rUvEpBTSnZ2PMv5piV50rGTBrcmPU4gsS7Byg=";
    };
    preInstall = ''
      patchShebangs ./install.sh
      sed -i '193c logoicon="Nixos"' ./install.sh
      sed -i '2s/0/1000/' ./core.sh
      sed -i '8s/\/usr\/share/$out/' ./core.sh
      sed -i 's/\/etc/$out\/etc/g' ./core.sh
      sed -i '132c magick "''${THEME_DIR}/background.jpg" -auto-orient "''${THEME_DIR}/background.jpg"' ./core.sh
      install -d $out/etc/default
      touch $out/etc/default/grub
      ${lib.optionalString (!builtins.isNull background) ''
        cp ${background} background.jpg
        chmod 777 background.jpg
      ''}
    '';
    installPhase = ''
      runHook preInstall
      ./install.sh -t ${theme} -p ${type} -i ${side} -c ${color} -s ${screen} -l ${logo}
      runHook postInstall
    '';
    postInstall = ''
      rm -rf $out/etc 
      ${lib.optionalString fixPath ''
        cd $out/grub/themes
        mv Elegant-${theme}-${type}-${side}-${color} ${name}
      ''}
    '';
    meta = {
      description = ''
        Elegant grub2 themes for all linux systems. Include "Elegant-wave-grub-themes", "Elegant-forest-grub-themes", "Elegant-mojave-grub-themes" and "Elegant-mountain-grub-themes"
      '';
      homepage = "https://github.com/vinceliuice/Elegant-grub2-themes";
      platforms = lib.platforms.linux;
      license = lib.licenses.gpl3Only;
      sourceProvenance = [ lib.sourceTypes.fromSource ];
    };
  }
else
  throw "Config not true. Please check your config."
