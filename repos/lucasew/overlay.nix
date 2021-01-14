with ./globalConfig.nix;
self: super:
let 
  cp = f: super.callPackage f {};
in
rec {
  comby = cp ./modules/comby/package.nix;
  custom_rofi = cp ./modules/custom_rofi/package.nix;
  dotenv = super.callPackage flake.inputs.dotenv {};
  latest = cp flake.inputs.nixpkgsLatest;
  minecraft = cp ./modules/minecraft/package.nix;
  mspaint = cp ./modules/mspaint/package.nix;
  neovim = cp ./modules/neovim/package.nix;
  p2k = cp flake.inputs.pocket2kindle ;
  peazip = cp ./modules/peazip/package.nix;
  pinball = cp ./modules/pinball/package.nix;
  redial_proxy = cp flake.inputs.redial_proxy;
  stremio = cp ./modules/stremio/overlay.nix;
  nodePackages = super.nodePackages
    // cp ./modules/node_clis/package_data/default.nix;
  nur = import nur {
    nurpkgs = super.pkgs;
    inherit (super) pkgs;
  };
  wrapDotenv = (file: script:
  let
    dotenvFile = (builtins.toString rootPath + "/secrets/" + (builtins.toString file));
    command = super.writeShellScript "dotenv-wrapper" script;
  in ''
    ${dotenv}/bin/dotenv "@${builtins.toString dotenvFile}" -- ${command} $*
    '');
}
