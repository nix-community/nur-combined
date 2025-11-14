{
  sources,
  version,
  pubspecLock,
  gitHashes,
  lib,
  flutter332,
  flutter335,
  makeDesktopItem,
  copyDesktopItems,
}:
let
  flutter = if version == "1.2.0" then flutter332 else flutter335;
in
flutter.buildFlutterApplication {
  inherit (sources) pname src;
  inherit version pubspecLock gitHashes;

  desktopItems = [
    (makeDesktopItem {
      name = "pixes";
      desktopName = "Pixes";
      genericName = "Pixes";
      exec = "pixes %u";
      comment = "Unofficial pixiv application";
      terminal = false;
      categories = [ "Utility" ];
      keywords = [
        "Flutter"
        "share"
        "images"
      ];
      mimeTypes = [ "x-scheme-handler/pixiv" ];
      extraConfig.X-KDE-Protocols = "pixiv";
      icon = "pixes";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
  ];

  postInstall = ''
    install -D debian/gui/pixes.png $out/share/pixmaps/pixes.png
    # for removing /nix/_temp/... rpaths introduced by flutter build
    # https://github.com/NixOS/nixpkgs/blob/c5ae371f1a6a7fd27823bc500d9390b38c05fa55/pkgs/development/compilers/flutter/build-support/build-flutter-application.nix#L184
    for f in $(find $out/app/$pname -executable -type f); do
      if patchelf --print-rpath "$f" | grep /nix/_temp; then # this ignores static libs (e,g. libapp.so) also
        echo "strip RPath of $f"
        newrp=$(patchelf --print-rpath $f | sed -r "s|/nix/_temp.*ephemeral:||g" | sed -r "s|/nix/_temp.*profile:||g")
        patchelf --set-rpath "$newrp" "$f"
      fi
    done
  '';

  meta = {
    description = "Unofficial pixiv app";
    homepage = "https://github.com/wgh136/pixes";
    mainProgram = "pixes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.unix;
  };
}
