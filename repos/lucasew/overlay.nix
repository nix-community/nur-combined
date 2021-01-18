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
    latest = cp flake.inputs.nixpkgsLatest;
    p2k = cp flake.inputs.pocket2kindle;
    redial_proxy = cp flake.inputs.redial_proxy;
    zls = cp flake.inputs.zls;
    custom_neovim = cp ./modules/neovim/package.nix;
    among_us = cp ./packages/among_us.nix;
    comby = cp ./packages/comby.nix;
    custom_rofi = cp ./packages/custom_rofi.nix;
    ets2 = cp ./packages/ets2.nix;
    funcoeszz = cp /home/lucasew/WORKSPACE/funcoeszz;
    minecraft = cp ./packages/minecraft.nix;
    mspaint = cp ./packages/mspaint.nix;
    peazip = cp ./packages/peazip.nix;
    pinball = cp ./packages/pinball.nix;
    stremio = cp ./packages/stremio.nix;
    usb_tixati = cp ./packages/usb_tixati.nix;
    nodePackages = super.nodePackages
    // cp ./modules/node_clis/package_data/default.nix;
    inherit dotenv;
    inherit wrapDotenv;
    nur = import flake.inputs.nur {
      inherit (super) pkgs;
      nurpkgs = super.pkgs;
    };
  })
]
