{
  lib,
  fetchFromGitHub,
  python3Packages,
  pygubu,
  fw-fanctrl,
  copyDesktopItems,
  makeDesktopItem,
}:

python3Packages.buildPythonApplication rec {
  pname = "fw-fanctrl-gui";
  version = "0.0.1-unstable-2025-04-16";

  src = fetchFromGitHub {
    owner = "leopoldhub";
    repo = "fw-fanctrl-gui";
    rev = "c0e4c8c62285a605fb4169cf2a02d4c02564cd47";
    sha256 = "046f4gqqglazc6nw369accg83sq3gizp50v1w4v5f6fd56zzdayk";
  };

  pyproject = true;

  nativeBuildInputs = [
    python3Packages.setuptools
    copyDesktopItems
  ];

  dependencies = with python3Packages; [
    pygubu
    customtkinter
    pystray
    blinker
    fw-fanctrl
    pygobject3
  ];

  # The application looks for resources relative to the package
  # setuptools should handle this via the configuration in pyproject.toml

  desktopItems = [
    (makeDesktopItem {
      name = "fw-fanctrl-gui";
      exec = "fw-fanctrl-gui";
      icon = "fw-fanctrl-gui";
      desktopName = "Framework Fan Control GUI";
      comment = "GUI for Framework Fan Control";
      categories = [
        "Settings"
        "System"
      ];
    })
  ];

  postInstall = ''
    install -Dm644 src/fw_fanctrl_gui/_resources/icon.ico $out/share/icons/hicolor/scalable/apps/fw-fanctrl-gui.ico
    # Better to have a png if possible, but ico might work or I can extract it if needed.
    # For now let's just use the ico.
  '';

  meta = with lib; {
    description = "A customtkinter GUI with a system tray for fw-fanctrl";
    homepage = "https://github.com/leopoldhub/fw-fanctrl-gui";
    license = licenses.bsd3;
    mainProgram = "fw-fanctrl-gui";
    platforms = platforms.linux;
  };
}
