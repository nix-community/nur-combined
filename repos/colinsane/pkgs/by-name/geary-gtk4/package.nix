# STATUS
# - DOES NOT BUILD
# - gets to 412/703, then fails when compiling all the src/client/ vala files
#   basic stuff like `Gtk.BindingSet` could not be found; `Gtk.Container`, `Gtk.EventButton`, `Gtk.Menu`...
# - seems i have been mislead by the commit messages/discussion and this port is only halfway to buildable.
{
  appstream-glib,
  desktop-file-utils,
  enchant2,
  fetchFromGitLab,
  folks,
  gcr_4,
  gmime3,
  gnome-online-accounts,
  gobject-introspection,
  gsound,
  gspell,
  gtk4,
  icu,
  isocodes,
  itstool,
  json-glib,
  lib,
  libadwaita,
  libpeas,
  libsecret,
  libstemmer,
  libunwind,
  libxml2,
  libytnef,
  meson,
  ninja,
  pkg-config,
  python3,
  sqlite,
  stdenv,
  vala,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:
stdenv.mkDerivation {
  pname = "geary-gtk4";
  version = "44.1-unstable-2023-10-17";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "geary";
    rev = "gnumdk/gtk4";
    hash = "sha256-gs9ZdNZL+Elm71OPg+Uk1+EGM9g5ac1HvHwlMGaLJv0=";
  };

  # --replace-fail "'client/web-process/web-process-extension.vala'" "# 'client/web-process/web-process-extension.vala'"
  postPatch = ''
    substituteInPlace src/console/main.vala \
      --replace-fail 'Gtk.ScrolledWindow(null, null);' 'Gtk.ScrolledWindow();' \
      --replace-fail 'scrolled_console.add' 'scrolled_console.set_child'
    substituteInPlace meson.build \
      --replace-fail 'webkitgtk_web_extension = dependency' '# webkitgtk_web_extension = dependency'
    substituteInPlace src/meson.build \
      --replace-fail 'web_process_sources,' "" \
      --replace-fail 'webkitgtk_web_extension,' ""

    chmod +x build-aux/git_version.py
    patchShebangs build-aux/git_version.py
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gobject-introspection
    itstool
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    appstream-glib
    enchant2
    folks
    gcr_4
    gmime3
    gnome-online-accounts
    gsound
    gspell
    gtk4
    icu
    isocodes
    json-glib
    libadwaita
    libpeas
    libsecret
    libstemmer
    libunwind
    libxml2
    libytnef
    sqlite
    webkitgtk_6_0
  ];

  mesonFlags = [
    "-Dprofile=release"
  ];

  meta = with lib; {
    broken = true;
    homepage = "https://wiki.gnome.org/Apps/Geary";
    description = "GNOME mail client, patched for gtk4";
    maintainers = with maintainers; [ colinsane ];
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
