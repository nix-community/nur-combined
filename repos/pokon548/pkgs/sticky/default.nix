{ lib
, desktop-file-utils
, fetchFromGitHub
, fetchYarnDeps
, fixup_yarn_lock
, gjs
, glib-networking
, gobject-introspection
, gst_all_1
, gtk4
, libadwaita
, libsoup_3
, meson
, ninja
, pkg-config
, stdenv
, wrapGAppsHook4
, yarn
, nodejs
}:

stdenv.mkDerivation rec {
  pname = "sticky";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "vixalien";
    repo = "sticky";
    rev = "2e5bf52aa6ebd7365aa1fb2439ef90806a56a578";
    hash = "sha256-D7z8U/9N8zpRSXUUZ48flrsD/3qLOBAK9gWQSXfh9P8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    nodejs
    pkg-config
    wrapGAppsHook4
    yarn
  ];

  buildInputs = [
    gjs
    glib-networking
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gtk4
    libadwaita
    libsoup_3
  ];

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-GThcufSAr/VYL9AWFOBY2FDXQZGY5L7TbBdadPh7CAc=";
  };

  preConfigure = ''
    export HOME="$PWD"
    yarn config --offline set yarn-offline-mirror $yarnOfflineCache
    ${fixup_yarn_lock}/bin/fixup_yarn_lock yarn.lock
  '';

  mesonFlags = [
    "-Dyarnrc=../.yarnrc"
  ];

  postFixup = ''
    sed -i "1 a imports.package._findEffectiveEntryPointName = () => 'com.vixalien.sticky';" $out/bin/.com.vixalien.sticky-wrapped
    ln -s $out/bin/com.vixalien.sticky $out/bin/sticky
  '';

  meta = with lib; {
    description = "A simple sticky notes app for GNOME";
    homepage = "https://github.com/vixalien/sticky";
    license = licenses.mit;
    maintainers = with maintainers; [ pokon548 ];
  };
}