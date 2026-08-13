{
  lib,
  fetchFromGitHub,
  python3Packages,
  systemd,
  polkit,
  bluez,
  gobject-introspection,
  wrapGAppsHook4,
  libadwaita,
  kdePackages,
  makeDesktopItem,
  copyDesktopItems,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "blueferry";
  version = "0.6.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "erikwb";
    repo = "blueferry";
    rev = "94b8642b04c70bc7580ef2c1cfd98a1b1d80da3b";
    hash = "sha256-Nf4hwZVwKOKiTEXz6fJrWR9UC+JWm0HHHrqi8aOY9as=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
    kdePackages.wrapQtAppsHook
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "io.weirdware.BlueFerry.Gtk";
      desktopName = "BlueFerry";
      genericName = "iPhone Bluetooth Bridge";
      comment = "Your iPhone's messages and notifications on the Linux desktop";
      exec = "blueferry-gtk";
      icon = "io.weirdware.BlueFerry.Gtk";
      terminal = false;
      categories = [
        "Network"
        "InstantMessaging"
        "GTK"
      ];
      keywords = [
        "iPhone"
        "SMS"
        "iMessage"
        "Bluetooth"
        "Notifications"
        "Messages"
      ];
      startupNotify = true;
    })
    (makeDesktopItem {
      name = "io.weirdware.BlueFerry.Qt";
      desktopName = "BlueFerry";
      genericName = "iPhone Bluetooth Bridge";
      comment = "Your iPhone's messages and notifications on Plasma";
      exec = "blueferry-qt";
      icon = "io.weirdware.BlueFerry.Qt";
      terminal = false;
      categories = [
        "Network"
        "InstantMessaging"
        "Qt"
        "KDE"
      ];
      keywords = [
        "iPhone"
        "SMS"
        "iMessage"
        "Bluetooth"
        "Notifications"
        "Messages"
      ];
      startupNotify = true;
    })
  ];

  buildInputs = [
    libadwaita
    kdePackages.kirigami
    kdePackages.qtdeclarative
  ];

  dependencies = [
    python3Packages.cryptography
    python3Packages.dbus-python
    python3Packages.typer
    python3Packages.textual
    python3Packages.pygobject3
    python3Packages.pyside6
  ];

  postPatch = ''
    substituteInPlace \
      src/blueferry/{bluetooth_capabilities,backend_lifecycle,pair_setup}.py \
      --replace-quiet /usr/bin/systemctl ${lib.getExe' systemd "systemctl"} \
      --replace-quiet /usr/bin/pkexec ${lib.getExe' polkit "pkexec"} \
      --replace-quiet /usr/bin/btmgmt ${lib.getExe' bluez "btmgmt"}
  '';

  postInstall = ''
    mkdir -p $out/share/{systemd/user,dbus-1/services}
    substitute systemd/blueferry.service $out/share/systemd/user/blueferry.service \
      --replace-fail /usr/bin/blueferry $out/bin/blueferry

    substitute packaging/arch/io.weirdware.BlueFerry.service \
      $out/share/dbus-1/services/io.weirdware.BlueFerry.service \
      --replace-fail /usr/bin/blueferry $out/bin/blueferry

    install -Dm644 data/io.weirdware.BlueFerry.xml \
      $out/share/dbus-1/interfaces/io.weirdware.BlueFerry.xml

    install -Dm644 data/icons/io.weirdware.BlueFerry.Gtk.svg \
      $out/share/icons/hicolor/scalable/apps/io.weirdware.BlueFerry.Gtk.svg
    install -Dm644 data/icons/io.weirdware.BlueFerry.Gtk.svg \
      $out/share/icons/hicolor/scalable/apps/io.weirdware.BlueFerry.Qt.svg
  '';

  dontWrapGApps = true;
  dontWrapQtApps = true;

  postFixup = ''
    wrapGApp $out/bin/blueferry-gtk
    wrapQtApp $out/bin/blueferry-qt
  '';

  passthru.updateScript = null;

  meta = {
    description = "iPhone iMessage/SMS and notifications bridge to Linux over Bluetooth";
    homepage = "https://github.com/erikwb/blueferry";
    license = lib.licenses.gpl2Only;
    mainProgram = "blueferry";
    platforms = lib.platforms.linux;
  };
})
