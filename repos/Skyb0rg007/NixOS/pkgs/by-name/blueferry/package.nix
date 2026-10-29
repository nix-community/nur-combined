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
  nix-update-script,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "blueferry";
  version = "0.9.0";
  __structuredAttrs = true;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "erikwb";
    repo = "blueferry";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YW8LT9vt3ejQcO/BSI72CJxoLNwrq3FKmq3yAD7KpJg=";
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
    python3Packages.phonenumbers
    python3Packages.pygobject3
    python3Packages.pyside6
    python3Packages.regex
    python3Packages.textual
    python3Packages.typer
  ];

  postPatch = ''
    substituteInPlace \
      src/blueferry/{bluez_setup,bluetooth_capabilities,backend_lifecycle,pair_setup}.py \
      --replace-quiet /usr/bin/systemctl ${lib.getExe' systemd "systemctl"} \
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "iPhone iMessage/SMS and notifications bridge to Linux over Bluetooth";
    homepage = "https://github.com/erikwb/blueferry";
    license = lib.licenses.gpl2Only;
    mainProgram = "blueferry";
    platforms = lib.platforms.linux;
  };
})
