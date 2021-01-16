with import ./globalConfig.nix;
with builtins;
let
  composeOverlay = items: self: super:
  with super.lib;
  foldl' (flip extends) (_: super) items self;
in composeOverlay [
  # (import "${flake.inputs.rust-overlay}/rust-overlay.nix")
  (self: super:
  let
    cp = f: (super.callPackage f) {};
    dotenv = cp flake.inputs.dotenv;
    wrapDotenv = (file: script:
    let
      dotenvFile = ((toString rootPath) + "/secrets/" + (toString file));
      command = super.writeShellScript "dotenv-wrapper" script;
    in ''
      ${dotenv}/bin/dotenv "@${toString dotenvFile}" -- ${command} $*
    '');

  in
  rec {
    lib = (super.lib or {}) // {
      inherit composeOverlay;
    };
    comby = cp ./modules/comby/package.nix;
    custom_rofi = cp ./modules/custom_rofi/package.nix;
    custom_neovim = cp ./modules/neovim/package.nix;
    latest = cp flake.inputs.nixpkgsLatest;
    minecraft = cp ./modules/minecraft/package.nix;
    mspaint = cp ./modules/mspaint/package.nix;
    p2k = cp flake.inputs.pocket2kindle;
    peazip = cp ./modules/peazip/package.nix;
    pinball = cp ./modules/pinball/package.nix;
    redial_proxy = cp flake.inputs.redial_proxy;
    stremio = cp ./modules/stremio/package.nix;
    among_us = cp ./nodes/acer-nix/modules/among_us/package.nix;
    zls = cp flake.inputs.zls;
    inherit dotenv;
    inherit wrapDotenv;
    nodePackages = super.nodePackages
    // cp ./modules/node_clis/package_data/default.nix;
    nur = import flake.inputs.nur {
      inherit (super) pkgs;
      nurpkgs = super.pkgs;
    };
  })
]
