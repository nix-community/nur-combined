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
  version = "50.1-unstable-2026-11-17";
  src = fetchFromGitHub {
    owner = "somepaulo";
    repo = "MoreWaita";
    rev = "fb37f62eceaa9b07d0ad6dfa719ebf38ed6d7921";
    hash = "sha256-xkjRJxkg1HfjBiNMLyn3vNlApQhA5Hpn537HSS8xvx0=";
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
