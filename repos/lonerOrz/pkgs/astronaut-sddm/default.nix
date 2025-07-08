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
  name = "astronaut";
  version = "11c0bf6147bbea466ce2e2b0559e9a9abdbcc7c3";

  src = fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = version;
    hash = "sha256-gBSz+k/qgEaIWh1Txdgwlou/Lfrfv3ABzyxYwlrLjDk=";
  };

  passthru.autoUpdate = false;

  propagatedUserEnvPkgs = with qt6; [
    qtsvg
    qtvirtualkeyboard
    qtmultimedia
  ];

  dontBuild = true;

  dontWrapQtApps = true;

  installPhase = ''
    themeDir="$out/share/sddm/themes/${name}"

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
