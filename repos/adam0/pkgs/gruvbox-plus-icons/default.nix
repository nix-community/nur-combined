{
  # keep-sorted start
  fetchFromGitHub,
  folder-color ? "plasma",
  gtk3,
  hicolor-icon-theme,
  kdePackages ? null,
  lib,
  plasma5Packages ? null,
  stdenvNoCC,
  # keep-sorted end
}: let
  breeze-icons =
    if kdePackages != null
    then kdePackages.breeze-icons
    else plasma5Packages.breeze-icons;
in
  stdenvNoCC.mkDerivation {
    pname = "gruvbox-plus-icons";
    version = "6.6.0-unstable-2026-10-14";

    src = fetchFromGitHub {
      owner = "SylEleuth";
      repo = "gruvbox-plus-icon-pack";
      rev = "533dc5a5dfa94ff1d14721d5be5761c04937db76";
      hash = "sha256-RmVr9+/eDojKmKOumwMG7PiFg/6N4JhLR/f1SV9L+bI=";
    };

    patches = [./folder-color.patch];

    nativeBuildInputs = [gtk3];

    propagatedBuildInputs = [
      # keep-sorted start
      breeze-icons
      hicolor-icon-theme
      # keep-sorted end
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/icons
      cp -r Gruvbox-Plus-Dark $out/share/icons/
      cp -r Gruvbox-Plus-Light $out/share/icons/
      patchShebangs scripts/folders-color-chooser
      ./scripts/folders-color-chooser -c ${folder-color}
      gtk-update-icon-cache $out/share/icons/Gruvbox-Plus-Dark
      gtk-update-icon-cache $out/share/icons/Gruvbox-Plus-Light

      runHook postInstall
    '';

    # keep-sorted start
    dontBuild = true;
    dontConfigure = true;
    dontDropIconThemeCache = true;
    dontWrapQtApps = true;
    # keep-sorted end

    meta = with lib; {
      # keep-sorted start
      description = "Icon pack for Linux desktops based on the Gruvbox color scheme";
      homepage = "https://github.com/SylEleuth/gruvbox-plus-icon-pack";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
      # keep-sorted end
    };
  }
