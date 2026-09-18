{
  lib,
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  python3,
  makeWrapper,
  qt5,
  xdg-utils,
  glib,
}:

let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      pyqt5
      dbus-python
    ]
  );
in
stdenv.mkDerivation {
  pname = "driftwm-desktop";
  version = "0-unstable-2026-09-05";

  src = fetchFromGitHub {
    owner = "C10udburst";
    repo = "driftwm-desktop";
    rev = "c7c52167e75fea0c629d0cef6d7aad98a2d8a36d";
    hash = "sha256-7hcapPzAcjhbfbIo5XCME4KEyUBwS4vC9KEBEa4ATuA=";
  };

  nativeBuildInputs = [
    makeWrapper
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    pythonEnv
    qt5.qtwayland
    qt5.qtbase
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/driftwm-desktop
    cp -r driftwm_desktop $out/lib/driftwm-desktop/
    cp driftwm-desktop $out/lib/driftwm-desktop/driftwm-desktop
    cp desktop_launchers.py $out/lib/driftwm-desktop/desktop_launchers.py

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/driftwm-desktop \
      --add-flags "$out/lib/driftwm-desktop/driftwm-desktop" \
      --prefix PATH : ${
        lib.makeBinPath [
          xdg-utils
          glib
        ]
      }

    ln -s $out/bin/driftwm-desktop $out/bin/desktop-launchers
    ln -s $out/bin/driftwm-desktop $out/bin/desktop_launchers.py

    runHook postInstall
  '';

  dontWrapQtApps = false;
  preFixup = ''
    wrapQtApp "$out/bin/driftwm-desktop"
  '';

  passthru.update-script = nix-update-script {
    extraArgs = [
      "--version=branch=master"
    ];
  };

  meta = with lib; {
    description = "Modular, spatial desktop icons manager for DriftWM";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "driftwm-desktop";
  };
}
