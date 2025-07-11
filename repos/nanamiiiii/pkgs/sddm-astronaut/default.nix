{
  lib,
  stdenvNoCC,
  kdePackages,
  fetchFromGitHub,
  formats,
  theme ? "astronaut",
  themeConfig ? null,
  unstableGitUpdater,
}:
let
  overwriteConfig = (formats.ini { }).generate "${theme}.conf.user" themeConfig;
in
stdenvNoCC.mkDerivation rec {
  name = "sddm-astronaut-theme";
  version = "0-unstable-2025-06-21";

  src = fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "3ef9f511fd072ff3dbb6eb3c1c499a71f338967e";
    hash = "sha256-33CzZ4vK1dicVzICbudk8gSRC/MExG+WnrE9wIWET14=";
  };

  # Avoid wrapping Qt binaries
  dontWrapQtApps = true;

  # Required Qt6 libraries for SDDM >= 0.21
  propagatedBuildInputs = [
    kdePackages.qtsvg
    kdePackages.qtmultimedia
    kdePackages.qtvirtualkeyboard
  ];

  buildPhase = ''
    runHook preBuild
    echo "No build required."
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    themeDir="$out/share/sddm/themes/${name}"

    mkdir -p $themeDir
    cp -r $src/* $themeDir

    install -dm755 "$out/share/fonts"
    cp -r $themeDir/Fonts/* $out/share/fonts/

    substituteInPlace "$themeDir/metadata.desktop" \
        --replace-fail "ConfigFile=Themes/astronaut.conf" "ConfigFile=Themes/${theme}.conf"

    ${lib.optionalString (lib.isAttrs themeConfig) ''
      install -dm755 "$themeDir/Themes"
      cp ${overwriteConfig} $themeDir/Themes/${theme}.conf.user
    ''}

    runHook postInstall
  '';

  # Propagate Qt6 libraries to user environment
  postFixup = ''
    mkdir -p $out/nix-support
    echo ${kdePackages.qtsvg} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.qtmultimedia} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.qtvirtualkeyboard} >> $out/nix-support/propagated-user-env-packages
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Series of modern looking themes for SDDM";
    homepage = "https://github.com/Keyitdev/sddm-astronaut-theme";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
