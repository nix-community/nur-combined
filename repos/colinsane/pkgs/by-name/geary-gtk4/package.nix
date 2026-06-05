# STATUS as of 2026-03-29:
# - builds
# - seems able to read and receive mail
# - adaptive to mobile widths
# - can NOT send emails: no "send" button is visible in the editor
# - does NOT render notifications for incoming mail
#
# see draft nixpkgs pr: <https://github.com/NixOS/nixpkgs/pull/431981/changes>
# see draft geary pr: <https://gitlab.gnome.org/GNOME/geary/-/merge_requests/892>
# see Nettika's port/"audit": <https://gitlab.gnome.org/nettika-cat/geary/-/tree/gtk-migration-audit>
{
  appstream-glib,
  cmake,
  desktop-file-utils,
  enchant_2,
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
  libpeas2,
  libsecret,
  libspelling,
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

  # use `git log --format=fuller` to see commit date
  version = "46.0-unstable-2026-03-07";
  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "onny";
    repo = "geary";
    # rev = "onny/gtk4-port";
    rev = "c0887334cf45612ba41f758f2eb2494e065c8b61";
    hash = "sha256-41OEU8u6jkORutTFGEK33agwWEzNjTWaDDTIr7pu93s=";
  };

  # build fails:
  # > src/client/meson.build:13:22: ERROR: File accounts/accounts-mailbox-editor-dialog.vala does not exist.
  # version = "46.0-unstable-2026-03-25";
  # src = fetchFromGitLab {
  #   domain = "gitlab.gnome.org";
  #   owner = "nettika-cat";
  #   repo = "geary";
  #   # rev = "gtk-migration-audit";  <https://gitlab.gnome.org/nettika-cat/geary/-/tree/gtk-migration-audit>
  #   rev = "533fd74a944060a9df1100076631072f962c2f16";
  #   hash = "sha256-oSkcd/0+OgHW7uv1GYJU6xrMzZWLl+CpEFmblhsq71w=";
  # };

  postPatch = ''
    # `locale` command is part of glibc; silence musl complaints
    substituteInPlace meson.build --replace-fail \
      "c_utf8_check = run_command('locale', '-a', check: true).stdout()" \
      "c_utf8_check = 'C.utf8'"

    chmod +x build-aux/git_version.py
    chmod +x desktop/geary-attach
    patchShebangs build-aux/git_version.py
  '';

  preFixup = ''
    # Add geary to path for geary-attach
    gappsWrapperArgs+=(--prefix PATH : "$out/bin")
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
    cmake
  ];

  buildInputs = [
    appstream-glib
    enchant_2
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
    libpeas2
    libsecret
    libspelling
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

  strictDeps = true;

  meta = {
    homepage = "https://wiki.gnome.org/Apps/Geary";
    description = "GNOME mail client, patched for gtk4";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
  };
}
