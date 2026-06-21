{ lib
, stdenv
, callPackage
, fetchurl
, fetchFromGitHub
, runCommand
, nix-update-script
, symlinkJoin
, commandLineArgs ? [ ]
}:
let
  pname = "xmcl-bin";

  common = callPackage ../xmcl/common.nix { };
  inherit (common) version srcArgs desktopItem mkLauncher installIcons meta;

  asarSuffix = if stdenv.isDarwin then "mac" else "linux";

  asar = fetchurl {
    url = "https://github.com/Voxelum/x-minecraft-launcher/releases/download/v${version}/app-${version}-${asarSuffix}.asar";
    hash =
      if stdenv.isDarwin then
        "sha256-14rI38GdzvHr8POeXZ7Jlndh6K62/10J6HfOxbHTEZo="
      else
        "sha256-1S6osAnsiKCToRTYDDGzwxwc62DMnw1p9PUYURvLhN0=";
    # 这个逻辑迟早得大改
    # 等 Nix 终于支持 Windows 的时候再说……
  };

  icons = fetchFromGitHub (srcArgs // {
    sparseCheckout = [ "xmcl-electron-app/icons" ];
    hash = "sha256-eCQQSmU23CJtECjoI/pTtiTrO2PbK3h+cgMjO3x+YlI=";
  });

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

  passthru.updateScript = nix-update-script { };

  meta = meta // {
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
}
