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
  version = "0-unstable-2026-06-17";

  src = fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "cd46736b4135a71700d2225d60eb8e85917585eb";
    hash = "sha256-5ys3pP5GgkrIua/4II8KiQbWCwK8PZK6Sj3lCMe9q1c=";
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
