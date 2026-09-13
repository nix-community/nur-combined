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
  version = "49-unstable-2026-09-13";
  src = fetchFromGitHub {
    owner = "somepaulo";
    repo = "MoreWaita";
    rev = "e1c90a5d3d9f97457ec09cd3a9ee8927889254e9";
    hash = "sha256-pv4N138Vz5n4+iYrQ21Ie/yUF1UMHuU8ZqjfRUKKb7k=";
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
