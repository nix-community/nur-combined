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
  version = "0-unstable-2025-08-04";

  src = fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "071ad6eb9be8c0f6465cfe23798dc4b99e4e4b49";
    hash = "sha256-3rvvQTWL5NytpylV7KuSyeHIjg3HDz8Xy4hoHShj0KU=";
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
