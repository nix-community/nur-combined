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
  version = "49-unstable-2026-09-08";
  src = fetchFromGitHub {
    owner = "somepaulo";
    repo = "MoreWaita";
    rev = "831b34d00dbc34e5307c11a7ecbe9a1543c1d5c2";
    hash = "sha256-FQi+u5xbJOpOGyd8S3Cxp5HhCy1096WHXHRKif1K7/c=";
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
