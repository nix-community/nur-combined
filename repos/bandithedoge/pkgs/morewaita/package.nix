{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenvNoCC,

  adwaita-icon-theme,
  adwaita-icon-theme-legacy,
  gtk3,
  hicolor-icon-theme,
  meson,
  ninja,
}:
stdenvNoCC.mkDerivation {
  pname = "morewaita";
  version = "50.1-unstable-2026-11-12";
  src = fetchFromGitHub {
    owner = "somepaulo";
    repo = "MoreWaita";
    rev = "af6b396ba91fa7d95facd7c8f64b6b6030f4fb5a";
    hash = "sha256-b2kzmfReg2a7nRYFIU2GZ6d49Z3IvZCU4WLwtFBqdxg=";
  };

  nativeBuildInputs = [
    gtk3
    meson
    ninja
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    adwaita-icon-theme-legacy
    hicolor-icon-theme
  ];

  postInstall = ''
    gtk-update-icon-cache -f $out/share/icons/MoreWaita
  '';

  dontDropIconThemeCache = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "An expanded Adwaita-styled companion icon theme with extra icons for popular apps to complement Gnome Shell's original icons";
    homepage = "https://github.com/somepaulo/MoreWaita";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
