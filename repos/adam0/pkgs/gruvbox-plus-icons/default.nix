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
    version = "6.4.0-unstable-2026-05-28";

    src = fetchFromGitHub {
      owner = "SylEleuth";
      repo = "gruvbox-plus-icon-pack";
      rev = "60ed02b2cb6f9197439da63e0e0367873eec17b0";
      hash = "sha256-S2P9tJz8rOiEI3dZARHzvz7Sp+2kcbhFzXAgwgUXL6I=";
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
