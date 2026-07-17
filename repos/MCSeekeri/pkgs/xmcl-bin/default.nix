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
  version = "0.61.0";
  srcArgs = {
    owner = "voxelum";
    repo = "x-minecraft-launcher";
    rev = "v${version}";
  };

  common = callPackage ../xmcl/common.nix { };
  inherit (common)
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
        "sha256-14rI38GdzvHr8POeXZ7Jlndh6K62/10J6HfOxbHTEZo="
      else
        "sha256-YLg8gwYQnthHqC9tpg0EK9zFhA1Wh04TY7TSYNOSPPg=";
    # 这个逻辑迟早得大改
    # 等 Nix 终于支持 Windows 的时候再说……
  };

  icons = fetchFromGitHub (
    srcArgs
    // {
      sparseCheckout = [ "xmcl-electron-app/icons" ];
      hash = "sha256-Z0QF8y9zM1cEXKE+LWJQiFRG7hDwMdLpH4k7X+5T//8=";
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

  passthru.updateScript = nix-update-script { };

  meta = meta // {
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
}
