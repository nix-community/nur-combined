{ lib, stdenv, pkgs, nodejs, makeDesktopItem, makeWrapper, electron }:

let
  nodePackages = import ./node2nix/node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  nodePackageName = with lib;
    head
      (map
        (entry: "caprine-${entry.caprine}")
        (filter
          (entry: hasAttr "caprine" entry)
          (importJSON ./node2nix/node-packages.json)));

  nodePackage = nodePackages.${nodePackageName};

  desktopItem = makeDesktopItem {
    name = nodePackage.packageName;
    exec = nodePackage.packageName;
    icon = nodePackage.packageName;
    desktopName = "Caprine";
    genericName = "IM Client";
    comment = "Elegant Facebook Messenger desktop app";
    categories = [ "GTK" "InstantMessaging" "Network" ];
    startupNotify = true;
  };
in
nodePackage.override {
  nativeBuildInputs = [ makeWrapper ];

  npmFlags = "--ignore-scripts";

  postInstall = ''
    # Compile Typescript sources
    ./node_modules/typescript/bin/tsc

    # Create desktop item
    mkdir -p "$out/share/applications"
    cp "${desktopItem}/share/applications/"* "$out/share/applications"

    # Link scalable icon
    mkdir -p "$out/share/icons/hicolor/scalable/apps"
    ln -s "$PWD/media/Icon.svg" "$out/share/icons/hicolor/scalable/apps/caprine.svg"

    # Create electron wrapper
    makeWrapper ${electron}/bin/electron "$out/bin/caprine" \
      --add-flags "$out/lib/node_modules/caprine" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland}}"
  '';

  meta = with lib; (nodePackage.meta // {
    homepage = "https://sindresorhus.com/caprine";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = electron.meta.platforms;
    mainProgram = nodePackage.packageName;
    broken = stdenv.isDarwin; # GPU process isn't usable. Goodbye.
  });
}
