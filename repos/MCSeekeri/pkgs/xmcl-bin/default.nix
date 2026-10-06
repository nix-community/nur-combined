{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  fetchFromGitHub,
  runCommand,
  nix-update-script,
  symlinkJoin,
  commandLineArgs ? [ ],
}:
let
  pname = "xmcl-bin";

  common = callPackage ../xmcl/common.nix { };
  inherit (common)
    version
    srcArgs
    desktopItem
    mkLauncher
    installIcons
    meta
    ;

  asarSuffix = if stdenv.isDarwin then "mac" else "linux";

  asar = fetchurl {
    url = "https://github.com/Voxelum/x-minecraft-launcher/releases/download/v${version}/app-${version}-${asarSuffix}.asar";
    hash =
      if stdenv.isDarwin then
        "sha256-ITwRG09nagtvg2M4qKbhx/0ixtlLlYfWNy9VGUyaAzM="
      else
        "sha256-hCrHJKc+rCy+REOzHjp8bj1rD2lkJa4AFu45zg1CJlo=";
    # 这个逻辑迟早得大改
    # 等 Nix 终于支持 Windows 的时候再说……
  };

  icons = fetchFromGitHub (
    srcArgs
    // {
      sparseCheckout = [ "xmcl-electron-app/icons" ];
      hash = "sha256-arEB0C6qPOYgMGZjLI9G79z2Hw5RF1woUMdERmrYb6M=";
    }
  );

  resources = runCommand "xmcl-bin-resources-${version}" { } ''
    install -Dm644 ${asar} "$out/share/xmcl/app.asar"

    ${installIcons "${icons}/xmcl-electron-app/icons"}
  '';

  launcher = mkLauncher { inherit resources commandLineArgs; };
in
symlinkJoin {
  inherit pname version;
  paths = [
    resources
    launcher
    desktopItem
  ];

  passthru = {
    updateScript = nix-update-script { };
    inherit asar icons;
  };

  meta = meta // {
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
}
