{
  stdenvNoCC,
  qt6,
  lib,
  fetchFromGitHub,
  formats,
  theme ? "astronaut",
  themeConfig ? null,
}:
let
  overwriteConfig = (formats.ini { }).generate "${theme}.conf.user" themeConfig;
in
stdenvNoCC.mkDerivation rec {
  pname = "astronaut";
  version = "0-unstable-2026-05-12";

  src = fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "8c85b9c8d00ce70e39320f77071dca2040544f19";
    hash = "sha256-+Z1igZ4BxRqXr/lxfHEr3I4n/sX8+AIwUr6JFO9yoWs=";
  };

  passthru.updateArgs = [ "--version=branch" ];

  propagatedUserEnvPkgs = with qt6; [
    qtsvg
    qtvirtualkeyboard
    qtmultimedia
  ];

  dontBuild = true;

  dontWrapQtApps = true;

  installPhase = ''
    themeDir="$out/share/sddm/themes/${pname}"

    mkdir -p $themeDir
    cp -r $src/* $themeDir

    install -dm755 "$out/share/fonts"
    cp -r $themeDir/Fonts/* $out/share/fonts/

    # Update metadata.desktop to load the chosen theme.
    substituteInPlace "$themeDir/metadata.desktop" \
      --replace-fail "ConfigFile=Themes/astronaut.conf" "ConfigFile=Themes/${theme}.conf"

    # Create theme.conf.user of the selected theme. To overwrite its configuration.
    ${lib.optionalString (lib.isAttrs themeConfig) ''
      install -dm755 "$themeDir/Themes"
      cp ${overwriteConfig} $themeDir/Themes/${theme}.conf.user
    ''}
  '';

  meta = {
    description = "Series of modern looking themes for SDDM";
    homepage = "https://github.com/Keyitdev/sddm-astronaut-theme";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    binaryNativeCode = false;
  };
}
