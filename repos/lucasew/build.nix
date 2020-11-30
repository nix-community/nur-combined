let
  globalConfig = import ./globalConfig.nix;
  nixpkgs = import globalConfig.repos.nixpkgs {
    overlays = [
      (import ./nodes/acer-nix/modules/webviews/overlay.nix)
      (import ./modules/zig/overlay.nix)
    ];
  };
  callPkg = path: nixpkgs.callPackage path {};
in 
with builtins;
(attrValues {
  comby = callPkg ./modules/comby/package.nix;
  rofi = callPkg ./modules/custom_rofi/package.nix;
  dotenv = callPkg ./modules/dotenv/package.nix;
  mspaint = callPkg ./modules/mspaint/package.nix;
  neovim = callPkg ./modules/neovim/package.nix;
  a22120 = callPkg ./modules/node_clis/package_22120.nix;
  pinball = callPkg ./modules/pinball/package.nix;
  stremio = callPkg ./modules/stremio/package.nix;
  yt = callPkg ./modules/youtube/package.nix;
  among_us = callPkg ./nodes/acer-nix/modules/among_us/package.nix;
  ets2 = callPkg ./nodes/acer-nix/modules/ets2/package.nix;
  usb_tixati = callPkg ./nodes/acer-nix/modules/usb_tixati/package.nix;
})
++ (import ./modules/vscode/extensions.nix {pkgs = nixpkgs;})
++ (with nixpkgs; [
  nodePackages.nativefier
  nodePackages.ts-node
  zls
])
