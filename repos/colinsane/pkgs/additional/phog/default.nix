{ lib
, stdenv
, fetchFromGitLab
, meson
, ninja
, pkg-config
, gcr
, glib
, gnome-desktop
, gtk3
, libgudev
, libjson
, json-glib
, libhandy
, networkmanager
, linux-pam
, systemd
, upower
, wayland
, libxkbcommon
, python3
, phoc
, bash
, gnome
, squeekboard ? null
, wayland-scanner
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "phog";
  version = "0.1.3";

  src = fetchFromGitLab {
    owner = "mobian1";
    repo = "phog";
    rev = version;
    hash = "sha256-zny1FUYKwVXVSBGTh8AFVtMBS7dWZHTKO2gkPNPSL2M=";
  };

  patches = [
    ./sway-compat.patch
  ];

  postPatch = ''
    patchShebangs build-aux/post_install.py
    sed -i /phog_plugins_dir/d build-aux/post_install.py
    substituteInPlace src/greetd.c \
      --replace '/usr/share/wayland-sessions' '/run/current-system/sw/share/wayland-sessions/' \
      --replace '/usr/share/xsessions' '/run/current-system/sw/share/xsessions'
  '' + lib.optionalString (squeekboard == null) ''
    substituteInPlace data/phog.in \
      --replace " & squeekboard" ""
  '';
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ bash squeekboard ]}
      --prefix XDG_DATA_DIRS : "${gnome.gnome-shell}/share/gsettings-schemas/${gnome.gnome-shell.name}"
    )
  '';


  mesonFlags = [ "-Dcompositor=${phoc}/bin/phoc" ];

  depsBuildBuild = [
    pkg-config
  ];

  buildInputs = [
    gcr
    glib
    gnome-desktop
    gtk3
    libgudev
    libjson
    json-glib
    libhandy
    networkmanager
    linux-pam
    systemd
    upower
    wayland
    libxkbcommon
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    glib
    wayland-scanner
    wrapGAppsHook
  ];

  meta = with lib; {
    description = "Greetd-compatible greeter for mobile phones";
    homepage = "https://gitlab.com/mobian1/phog/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ matthewcroughan ];
  };
}
