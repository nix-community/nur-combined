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
        "sha256-YmeIoZ/kyBq36Rijrq71GjQLdYo+Ej92AijcBI2LiMw="
      else
        "sha256-Vtj+pbRwvUdP6M9trOLwmzhWPD+yym71I49euOxoxdQ=";
    # 这个逻辑迟早得大改
    # 等 Nix 终于支持 Windows 的时候再说……
  };

  icons = fetchFromGitHub (
    srcArgs
    // {
      sparseCheckout = [ "xmcl-electron-app/icons" ];
      hash = "sha256-Og13V88tde6kAArfMU6ZSkA8IQTBDcME/OIubRpyARQ=";
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
