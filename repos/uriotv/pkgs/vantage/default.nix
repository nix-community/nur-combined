{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  makeDesktopItem,
  python3,
  kdePackages,
  coreutils,
  findutils,
  gawk,
  gnugrep,
  gnused,
}:

let
  # Everything the QML scripts and the Tweaks window derive from their own
  # location: scripts/apply-*.sh read presets/ through `dirname $0/..`, and
  # tweaks/vantage_config.py reads effect/contents/config/main.xml the same way.
  # The tree therefore stays together under share/vantage, and the paths KWin
  # and Plasma scan for are copies of the matching subdirectories.
  tree = "$out/share/vantage";

  # Upstream scripts call `qdbus6`. Qt 6 ships the same client as `qdbus`
  # (qttools), and NixOS provides no `qdbus6` binary.
  runtimePath = lib.makeBinPath [
    kdePackages.kconfig # kwriteconfig6, kreadconfig6
    kdePackages.qttools # qdbus
    coreutils
    findutils
    gawk
    gnugrep
    gnused
  ];

  tweaksPython = python3.withPackages (ps: [ ps.pyside6 ]);

  desktopItem = makeDesktopItem {
    name = "vantage-tweaks";
    desktopName = "Vantage Tweaks";
    comment = "Configure the Vantage overview, app grid and dock";
    exec = "vantage-tweaks";
    icon = "preferences-desktop";
    categories = [
      "Settings"
      "DesktopSettings"
    ];
    keywords = [
      "vantage"
      "overview"
      "tweaks"
    ];
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vantage";
  # Upstream has no tags; the version follows the commit date like other
  # branch-tracking packages here.
  version = "0-unstable-2026-11-28";

  src = fetchFromGitHub {
    owner = "VaZark";
    repo = "Vantage";
    rev = "67e7642aca18887ace186dcfaa8aba51faf2778c";
    hash = "sha256-HBLcwNihc3+FwPjXSWNeHf3+SJgBmXA8qOI+LXa3RpM=";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p ${tree}
    cp -r effect script plasmoid scripts presets tweaks ${tree}/

    # Discovered by KWin and Plasma wherever they appear in XDG_DATA_DIRS.
    mkdir -p $out/share/kwin/effects $out/share/kwin/scripts \
      $out/share/plasma/plasmoids
    cp -r effect $out/share/kwin/effects/vantage
    cp -r script $out/share/kwin/scripts/vantage-script
    cp -r plasmoid/vantage-launcher $out/share/plasma/plasmoids/io.github.vazark.vantage.launcher
    cp -r plasmoid/vantage-power $out/share/plasma/plasmoids/io.github.vazark.vantage.power

    install -Dm644 ${desktopItem}/share/applications/vantage-tweaks.desktop \
      $out/share/applications/vantage-tweaks.desktop

    # One wrapper per script: the settings editors get the KDE CLI tools, and the
    # qdbus6 shim below stands in for Qt's `qdbus`.
    mkdir -p $out/bin $out/libexec/vantage/bin
    printf '#!/bin/sh\nexec %s "$@"\n' "${kdePackages.qttools}/bin/qdbus" \
      > $out/libexec/vantage/bin/qdbus6
    chmod +x $out/libexec/vantage/bin/qdbus6

    for script in apply-preset.sh apply-dock.sh apply-topbar.sh workspace-wallpaper.sh; do
      makeWrapper ${tree}/scripts/$script "$out/bin/vantage-''${script%.sh}" \
        --prefix PATH : "$out/libexec/vantage/bin:${runtimePath}"
    done
    makeWrapper ${tweaksPython}/bin/python3 "$out/bin/vantage-apply-panel-look" \
      --add-flags ${tree}/scripts/apply-panel-look.py \
      --prefix PATH : "$out/libexec/vantage/bin:${runtimePath}"

    # PySide6 supplies Qt itself; the QML side only needs QtQuick modules, which
    # ship with it. `here` in tweaks/vantage-tweaks resolves the QML and the
    # settings schema from the installed tree.
    makeWrapper ${tweaksPython}/bin/python3 "$out/bin/vantage-tweaks" \
      --add-flags ${tree}/tweaks/vantage-tweaks \
      --prefix PATH : "$out/libexec/vantage/bin:${runtimePath}"

    runHook postInstall
  '';

  meta = {
    description = "Configurable KWin overview with app grid, dock and two Plasma applets";
    longDescription = ''
      A KWin effect providing a workspace and application overview with search,
      app grid and dock, a KWin script that drives the workspace behaviour, the
      Vantage Launcher and Vantage Power Plasma applets, and a PySide6 settings
      window. It uses KWin and Plasma private QML modules, so a Plasma update can
      break it at runtime; the package itself only installs QML and scripts.
    '';
    homepage = "https://github.com/VaZark/Vantage";
    license = lib.licenses.gpl2Plus;
    mainProgram = "vantage-tweaks";
    platforms = lib.platforms.linux;
  };
})
