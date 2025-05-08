{ copyDesktopItems
, fetchzip
, fetchFromGitHub
, lib
, makeDesktopItem
, makeWrapper
, nix-update-script
, stdenv

  # Dependencies
, gtk2-x11
, mono
}:

let
  inherit (lib) getExe;
in
stdenv.mkDerivation (nbt-explorer: {
  pname = "nbt-explorer";
  version = "2.8.0";

  src = fetchzip {
    url = "https://github.com/jaquadro/NBTExplorer/releases/download/v${nbt-explorer.version}-win/NBTExplorer-${nbt-explorer.version}.zip";
    hash = "sha256-T0FLxuzgVHBz78rScPC81Ns2X1Mw/omzvYJVRQM24iU=";
    stripRoot = false;
  };

  iconSrc = fetchFromGitHub {
    owner = "jaquadro";
    repo = "NBTExplorer";
    rev = "d29f249d7e489eaa4ccf8ba5b661cfa6ae0466ff";
    sparseCheckout = [ "NBTExplorer/Resources/Dead_Bush_256.png" ];
    hash = "sha256-Hq3VYZ4IztUghN2AqYB7KZIALfoinMDyEn2MjQ9eilE=";
  };

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      genericName = "Minecraft data editor";
      desktopName = "NBTExplorer";
      name = nbt-explorer.pname;
      icon = nbt-explorer.pname;
      exec = "@out@/bin/nbt-explorer";
    })
  ];

  nativeBuildInputs = [ copyDesktopItems makeWrapper ];
  postInstall = ''
    mkdir -p $out/lib
    cp --target-directory $out/lib \
      $src/NBTExplorer.exe \
      $src/NBTModel.dll \
      $src/Substrate.dll

    makeWrapper ${getExe mono} $out/bin/nbt-explorer \
      --add-flags "$out/lib/NBTExplorer.exe" \
      --suffix LD_LIBRARY_PATH : ${gtk2-x11}/lib

    install -D $iconSrc/NBTExplorer/Resources/Dead_Bush_256.png $out/share/icons/${nbt-explorer.pname}.png
  '';

  preFixup = ''
    substituteAllInPlace $out/share/applications/*
  '';

  # FIXME: “replace() argument 1 must be str, not None” at nix_update/update.py:39
  # passthru.updateScript = nix-update-script {
  #   extraArgs = [ "--version-regex" "(.*)-win" ];
  # };

  meta = {
    description = "Graphical NBT editor for all Minecraft NBT data sources";
    homepage = "https://github.com/jaquadro/NBTExplorer";
    license = lib.licenses.mit;
    mainProgram = "nbt-explorer";
  };
})
