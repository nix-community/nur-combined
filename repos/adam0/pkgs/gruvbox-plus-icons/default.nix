{
  # keep-sorted start
  fetchFromGitHub,
  folder-color ? "plasma",
  gnome-icon-theme,
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
    version = "6.5.0-unstable-2026-07-16";

    src = fetchFromGitHub {
      owner = "SylEleuth";
      repo = "gruvbox-plus-icon-pack";
      rev = "e47976ca61a9db0dcf2b7dbcd834028c4b1c4c92";
      hash = "sha256-1xNUh/GRsnannzVGjPHggyE2lrDGMWdOSBnlobeNlBg=";
    };

    patches = [./folder-color.patch];

    nativeBuildInputs = [gtk3];

    propagatedBuildInputs = [
      # keep-sorted start
      breeze-icons
      gnome-icon-theme
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
