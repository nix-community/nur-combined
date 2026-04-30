{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  glib,
  gtk3,
  gdk-pixbuf,
  wrapGAppsHook3,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "appmenu-gtk-module";
  version = "25.04";

  src = fetchFromGitLab {
    owner = "vala-panel-project";
    repo = "vala-panel-appmenu";
    tag = finalAttrs.version;
    hash = "sha256-v5J3nwViNiSKRPdJr+lhNUdKaPG82fShPDlnmix5tlY=";
  };

  sourceRoot = "source/subprojects/appmenu-gtk-module";

  # Fix gtk3 module target dir. Proper upstream solution should be using define_variable.
  env.PKG_CONFIG_GTK__3_0_LIBDIR = "${placeholder "out"}/lib";

  mesonFlags = [
    (lib.mesonOption "gtk" "3")
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    glib # glib-compile-schemas + setup hook for gsettings install dir
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
  ];

  # Upstream meson installs the gschema XML but never compiles it.
  postInstall = ''
    glib-compile-schemas "$out/share/glib-2.0/schemas"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GTK module that exports application menus over DBusMenu";
    homepage = "https://gitlab.com/vala-panel-project/vala-panel-appmenu/-/tree/${finalAttrs.version}/subprojects/appmenu-gtk-module";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ codgician ];
    platforms = lib.platforms.linux;
  };
})
