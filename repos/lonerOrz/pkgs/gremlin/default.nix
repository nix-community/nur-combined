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
  bash,
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
    rev = "8f1e6acaa286613611f248b4190d67f72765e8a9";
    hash = "sha256-U7xwslnEuKmSnTZ5i68+rPhhgPeSfxrfuN4vzyn6jdA=";
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
    mkdir -p $out/share/linux-desktop-gremlin/{src,scripts}
    cp -r $src/src/* $out/share/linux-desktop-gremlin/src/
    cp -r $src/spritesheet $out/share/linux-desktop-gremlin/spritesheet
    cp -r $src/sounds $out/share/linux-desktop-gremlin/sounds

    install -Dm644 $src/config.json $out/share/linux-desktop-gremlin/config.json
    jq '.Systray = true' $src/config.json > $out/share/linux-desktop-gremlin/config.json # enable tray

    install -Dm755 $src/scripts/gremlin-picker.sh $out/share/linux-desktop-gremlin/scripts/gremlin-picker.sh
    sed -i "s|./run.sh \"\$pick\"|$out/bin/linux-desktop-gremlin \"\$pick\"|" \
      $out/share/linux-desktop-gremlin/scripts/gremlin-picker.sh

    install -Dm644 $src/icon.png $out/share/icons/hicolor/256x256/apps/linux-desktop-gremlin.png

    mkdir -p $out/{bin,libexec}
    ln -s $out/bin/linux-desktop-gremlin $out/bin/gremlin
  '';

  postFixup =
    let
      binPath = lib.makeBinPath [
        python3
        bash
        rofi
      ];
    in
    ''
      wrapProgram $out/bin/linux-desktop-gremlin \
        "''${gappsWrapperArgs[@]}" \
        --prefix PYTHONPATH : $out/share/linux-desktop-gremlin \
        --set QT_QPA_PLATFORM xcb \
        --prefix LD_LIBRARY_PATH : ${pipewire}/lib \
        --prefix PATH : ${binPath}

      makeWrapper $out/share/linux-desktop-gremlin/scripts/gremlin-picker.sh $out/bin/gremlin-picker \
        --prefix PYTHONPATH : $out/share/linux-desktop-gremlin \
        --prefix PATH : ${binPath}
    '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Linux Desktop Gremlins brings animated mascots to your Linux desktop.";
    homepage = "https://github.com/iluvgirlswithglasses/linux-desktop-gremlin";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "gremlin";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
