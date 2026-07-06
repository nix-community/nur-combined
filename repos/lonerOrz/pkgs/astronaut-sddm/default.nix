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
  version = "0-unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "292c87b770ff9eab1903dd2c6ddff466faf87fb0";
    hash = "sha256-O/EMJc1j2TRF3W+vuurzA9j5eG1OXSjGFrYxQbp99KU=";
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
