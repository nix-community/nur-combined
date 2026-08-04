{ copyDesktopItems
, fetchzip
, fetchFromGitHub
, lib
, makeDesktopItem
, makeWrapper
, nix-update-script
, stdenv
, xdg-utils

  # Dependencies
, gtk2-x11
, mono
}:

let
  inherit (builtins) placeholder;
  inherit (lib) getExe licenses;
in
stdenv.mkDerivation (nbt-explorer: {
  pname = "nbt-explorer";
  version = "2.8.0";
  meta = {
    description = "Graphical NBT editor for all Minecraft NBT data sources";
    homepage = "https://github.com/jaquadro/NBTExplorer";
    license = licenses.mit;
    mainProgram = "nbt-explorer";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex" "(.*)-win" ];
  };

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
      exec = "${placeholder "out"}/bin/nbt-explorer";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    xdg-utils
  ];

  postInstall = ''
    mkdir --parents "$out/lib"
    cp --target-directory "$out/lib" \
      'NBTExplorer.exe' \
      'NBTModel.dll' \
      'Substrate.dll'

    makeWrapper ${getExe mono} "$out/bin/nbt-explorer" \
      --add-flags "$out/lib/NBTExplorer.exe" \
      --suffix LD_LIBRARY_PATH : '${gtk2-x11}/lib'

    env XDG_DATA_HOME="$out/share" \
      xdg-icon-resource install --noupdate --novendor \
        --context 'apps' --size '256' "$iconSrc/NBTExplorer/Resources/Dead_Bush_256.png" '${nbt-explorer.pname}'
  '';
})
