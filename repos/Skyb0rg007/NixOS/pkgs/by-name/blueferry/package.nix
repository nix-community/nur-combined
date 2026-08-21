{
  lib,
  fetchFromGitHub,
  python3Packages,
  systemd,
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
  version = "0.7.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "erikwb";
    repo = "blueferry";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xQpqZ4exzHy0zs/XWUta18u4zqfNC0ioBfEW36GbA5w=";
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
      icon = "io.weirdware.BlueFerry";
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
      icon = "io.weirdware.BlueFerry";
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
      src/blueferry/{bluez_setup,bluetooth_capabilities,backend_lifecycle,pair_setup}.py \
      --replace-quiet /usr/bin/systemctl ${lib.getExe' systemd "systemctl"} \
      --replace-quiet /usr/bin/pkexec /run/wrappers/bin/pkexec \
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

    install -Dm644 data/icons/io.weirdware.BlueFerry.svg \
      $out/share/icons/hicolor/scalable/apps/io.weirdware.BlueFerry.svg
  '';

  dontWrapGApps = true;
  dontWrapQtApps = true;

  postFixup = ''
    wrapGApp $out/bin/blueferry-gtk
    wrapQtApp $out/bin/blueferry-qt
  '';

  meta = {
    description = "iPhone iMessage/SMS and notifications bridge to Linux over Bluetooth";
    homepage = "https://github.com/erikwb/blueferry";
    license = lib.licenses.gpl2Only;
    mainProgram = "blueferry";
    platforms = lib.platforms.linux;
  };
})
