{
  lib,
  fetchFromGitHub,
  python3Packages,
  makeDesktopItem,
  copyDesktopItems,
  qt6,
  xorg,
  pipewire,
  wrapGAppsHook3,
  jq,
  python3,
  rofi,
  libxcb,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-image,
}:

python3Packages.buildPythonApplication {
  pname = "gremlin";
  version = "0-unstable-2025-12-11";

  src = fetchFromGitHub {
    owner = "iluvgirlswithglasses";
    repo = "linux-desktop-gremlin";
    rev = "0568a6b7d0a245800234279b5157b2a0403b1f5a";
    hash = "sha256-FmJ6+OZXQlRZk2DCH1CYW6WEtVF0DqojwVj0xy8DacY=";
  };

  pyproject = true;

  desktopItems = [
    (makeDesktopItem {
      name = "gremlin";
      desktopName = "Gremlin";
      icon = "linux-desktop-gremlin";
      exec = "gremlin";
      comment = "Linux desktop gremlin";
      categories = [ "Utility" ];
    })
    (makeDesktopItem {
      name = "gremlin-picker";
      desktopName = "Gremlin Picker";
      icon = "linux-desktop-gremlin";
      exec = "gremlin-picker";
      comment = "Pick your favorite gremlin";
      categories = [ "Utility" ];
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    python3Packages.setuptools
    python3Packages.wheel
    wrapGAppsHook3
    qt6.wrapQtAppsHook
    jq
  ];

  propagatedBuildInputs =
    with python3Packages;
    [
      pyside6
      qt6.qtbase
      qt6.qtwayland
      pipewire
    ]
    ++ (with xorg; [
      libX11
      libXcursor
      libXrandr
      libXi
      libXrender
      libXext
    ])
    ++ [
      libxcb
      libxcb-cursor
      libxcb-keysyms
      libxcb-render-util
      libxcb-image
    ];

  postInstall = ''
    mkdir -p $out/share/linux-desktop-gremlin/src

    cp -r $src/src/* $out/share/linux-desktop-gremlin/src/
    cp -r $src/gremlins $out/share/linux-desktop-gremlin/gremlins
    cp -r $src/images $out/share/linux-desktop-gremlin/images

    install -Dm644 $src/config.json \
      $out/share/linux-desktop-gremlin/config.json
    jq '.Systray = true' \
      $src/config.json > \
      $out/share/linux-desktop-gremlin/config.json

    install -Dm644 \
      $src/icon.png \
      $out/share/icons/hicolor/256x256/apps/linux-desktop-gremlin.png

    ln -s $out/bin/linux-desktop-gremlin $out/bin/gremlin
  '';

  postFixup =
    let
      binPath = lib.makeBinPath [ rofi ];
      runtimePython = python3.withPackages (ps: [ ps.pyside6 ]);
    in
    ''
      wrapProgram $out/bin/linux-desktop-gremlin \
        "''${gappsWrapperArgs[@]}" \
        --set QT_QPA_PLATFORM xcb \
        --prefix PYTHONPATH : $out/share/linux-desktop-gremlin \
        --prefix LD_LIBRARY_PATH : ${pipewire}/lib \
        --prefix PATH : ${binPath}

      makeWrapper ${runtimePython}/bin/python $out/bin/gremlin-select \
        "''${gappsWrapperArgs[@]}" \
        --set QT_QPA_PLATFORM xcb \
        --prefix PYTHONPATH : $out/share/linux-desktop-gremlin \
        --chdir $out/share/linux-desktop-gremlin \
        --add-flags "-m src.picker"

      cat > $out/bin/gremlin-picker <<EOF
      #!/usr/bin/env bash
      set -e

      pick="\$($out/bin/gremlin-select)"

      if [ -n "\$pick" ]; then
        exec $out/bin/linux-desktop-gremlin "\$pick"
      fi
      EOF

      chmod +x $out/bin/gremlin-picker
    '';

  passthru.updateScript = ./update.sh;

  # 等待上游素材下载逻辑完善
  passthru.autoUpdate = false;

  meta = {
    description = "Linux Desktop Gremlins brings animated mascots to your Linux desktop.";
    homepage = "https://github.com/iluvgirlswithglasses/linux-desktop-gremlin";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "gremlin";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
