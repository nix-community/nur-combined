let
  globalConfig = import ./globalConfig.nix;
  nixpkgs = import globalConfig.repos.nixpkgs {};
in 
with builtins;
(attrValues {
  comby = import ./modules/comby/package.nix;
  rofi = import ./modules/custom_rofi/package.nix;
  dotenv = import ./modules/dotenv/package.nix;
  mspaint = import ./modules/mspaint/package.nix;
  neovim = import ./modules/neovim/package.nix;
  a22120 = import ./modules/node_clis/package_22120.nix;
  pinball = import ./modules/pinball/package.nix;
  stremio = import ./modules/stremio/package.nix;
  yt = import ./modules/youtube/package.nix;
  zls = (import ./modules/zig/overlay.nix nixpkgs nixpkgs).zls;
  among_us = import ./nodes/acer-nix/modules/among_us/package.nix;
  ets2 = import ./nodes/acer-nix/modules/ets2/package.nix;
  usb_tixati = import ./nodes/acer-nix/modules/usb_tixati/package.nix;

})
++ (import ./modules/vscode/extensions.nix {pkgs = nixpkgs;})
++ (attrValues (import ./nodes/acer-nix/modules/webviews/overlay_data/composition.nix {pkgs = nixpkgs;}))
