{
  description = "nixcfg";

  inputs = {
    bumpkin.url = "github:lucasew/bumpkin";
    bumpkin.inputs.nixpkgs.follows = "nixpkgs";

    cloud-savegame.url = "github:lucasew/cloud-savegame";
    cloud-savegame.flake = false;

    nix-index-database.url = "github:Mic92/nix-index-database";

    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    impermanence.url = "github:nix-community/impermanence";

    nixos-hardware.url = "github:lucasew/nixos-hardware/openrgb-defaults";

    nbr.url = "github:nixosbrasil/nixpkgs-brasil";
    nbr.inputs.nixpkgs.follows = "nixpkgs";
    nbr.inputs.flake-utils.follows = "flake-utils";

    nur.url = "github:nix-community/nur";

    nix-on-droid.url = "github:t184256/nix-on-droid";
    nix-on-droid.inputs.home-manager.follows = "home-manager";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    betterdiscord-addons.url = "github:mwittrien/BetterDiscordAddons?dir=Plugins";
    betterdiscord-addons.flake = false;

    nix-requirefile.url = "github:lucasew/nix-requirefile";
    nix-requirefile.flake = false;

    borderless-browser.url = "github:lucasew/borderless-browser.nix";
    borderless-browser.flake = false;

    nix-colors.url = "github:Misterio77/nix-colors";
    nix-colors.inputs.nixpkgs-lib.follows = "nixpkgs-lib";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";

    flake-utils.url = "github:numtide/flake-utils";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    cf-torrent.url = "github:lucasew/cf-torrent";
    cf-torrent.flake = false;

    nixgram.url = "github:lucasew/nixgram";
    nixgram.flake = false;

    simple-dashboard.url = "github:lucasew/simple-dashboard";
    simple-dashboard.flake = false;

    telegram-sendmail.url = "github:lucasew/telegram-sendmail";
    telegram-sendmail.flake = false;

    redial-proxy.url = "github:lucasew/redial_proxy";
    redial-proxy.flake = false;

    climod.url = "github:nixosbrasil/climod";
    climod.flake = false;

  };

  outputs = {
      self
    , bumpkin
    , nix-index-database
    , nixpkgs
    , home-manager
    , impermanence
    , nbr
    , nur
    , nixos-hardware
    , ...
  }@inputs:
  let
    inherit (builtins) concatStringsSep;

    system = builtins.currentSystem or "x86_64-linux";

    bootstrapPkgs = import nixpkgs {
      inherit system;
      overlays = []; # essential, infinite loop if not when using overlays
    };

    defaultNixpkgs = import ./nix/lib/patchNixpkgs.nix {
      inherit nixpkgs system bootstrapPkgs;
      patches = [ ];
    };

    pkgs = mkPkgs { inherit system; };

    mapAttrValues = pkgs.callPackage ./nix/lib/mapAttrValues.nix {};

    mkPkgs = {
      nixpkgs ? defaultNixpkgs
    , config ? {}
    , overlays ? []
    , disableOverlays ? false
    , system ? builtins.currentSystem
    }: import nixpkgs {
      localSystem = system;
      config = config // {
        allowUnfree = true;
        permittedInsecurePackages = [
            "python-2.7.18.6"
            "electron-18.1.0"
            "electron-21.4.0"
            "openssl-1.1.1u"
            "openssl-1.1.1v"
        ];
      };
      overlays = if disableOverlays then [] else (overlays ++ (builtins.attrValues self.outputs.overlays));
    };

    global = rec {
      username = "lucasew";
      email = "lucas59356@gmail.com";
      nodeIps = {
        riverwood = { ts = "100.107.51.95";   zt = "192.168.69.2"; };
        whiterun =  { ts = "100.85.38.19";    zt = "192.168.69.1"; };
        phone =     { ts = "100.108.254.101"; zt = "192.168.69.4"; };
      };
      selectedDesktopEnvironment = "i3";
      rootPath = "/home/${username}/.dotfiles";
      rootPathNix = "${rootPath}";
      environmentShell = with pkgs; ''
        export NIXPKGS_ALLOW_UNFREE=1
        if [[ ! -v NIXCFG_ROOT_PATH ]]; then
          export NIXCFG_ROOT_PATH=~/.dotfiles
        fi
        export LUA_PATH="${concatStringsSep ";" [
          ''$(realpath ${fennel}/share/lua/*)/?.lua''
          "$NIXCFG_ROOT_PATH/scripts/?.lua"
          "$NIXCFG_ROOT_PATH/scripts/?/index.lua"
        ]}"
        export PATH="${concatStringsSep ":" [
          "$PATH"
          "$NIXCFG_ROOT_PATH/bin"
        ]}"
        export LUA_INIT="pcall(require, 'adapter.fennel')"
        export NIX_PATH=nixpkgs=${defaultNixpkgs}:nixpkgs-overlays=$NIXCFG_ROOT_PATH/nix/compat/overlay.nix:home-manager=${home-manager}:nur=${nur}
        export SD_ROOT=$NIXCFG_ROOT_PATH/bin
        export SD_EDITOR=$EDITOR
        export SD_CAT=cat
      '';
    };

    extraArgs = {
      inherit self;
      inherit global;
      cfg = throw "your past self made a trap for non compliant code after a migration you did, now follow the stacktrace and go fix it";
    };

    overlays = {
      nix-requirefile = import "${inputs.nix-requirefile}/overlay.nix";
      borderless-browser = import "${inputs.borderless-browser}/overlay.nix";
      rust-overlay = import "${inputs.rust-overlay}/rust-overlay.nix";
      zzzthis = import ./nix/overlay.nix self;
    };
  in {
    # inherit (extraArgs) bumpkin;
    inherit global;
    inherit overlays;
    inherit pkgs;
    inherit self;

    colors = inputs.nix-colors.colorschemes."classic-dark";

    homeConfigurations = pkgs.callPackage ./nix/homes {
      inherit extraArgs;
      nodes = {
        main = { modules = [ ./nix/homes/main ]; inherit pkgs; };
      };
    };

    nixosConfigurations = pkgs.callPackage ./nix/nodes {
      inherit extraArgs;
      nodes = {
        ravenrock = { modules = [ ./nix/nodes/ravenrock ]; inherit pkgs; };
        riverwood = { modules = [ ./nix/nodes/riverwood ]; inherit pkgs; };
        whiterun  = { modules = [ ./nix/nodes/whiterun  ]; inherit pkgs; };
        recovery  = { modules = [ ./nix/nodes/recovery  ]; inherit pkgs; };
        demo      = { modules = [ ./nix/nodes/demo      ]; inherit pkgs; };
      };
    };

    nixOnDroidConfigurations = pkgs.callPackage ./nix/nixOnDroidConfigurations {
      inherit extraArgs mkPkgs;
      nodes = {
        default = { modules = [ ./nix/nixOnDroid/default ]; system = "aarch64-linux"; };
      };
    };

    devShells.${system}.default = pkgs.mkShell {
      name = "nixcfg-shell";
      buildInputs = with pkgs; [
        ctl
        pyinfra
        script-directory
        bumpkin.packages.${system}.default
        (writeShellScriptBin "bumpkin-bump" ''
          if [ -v NIXCFG_ROOT_PATH ]; then
              bumpkin eval -p -i "$NIXCFG_ROOT_PATH/bumpkin.json" -o "$NIXCFG_ROOT_PATH/bumpkin.json.lock" "$@"
          else
            exit 1
          fi
        '')
        (writeShellScriptBin "bumpkin-list" ''
          if [ -v NIXCFG_ROOT_PATH ]; then
            bumpkin list -i "$NIXCFG_ROOT_PATH/bumpkin.json" -o "$NIXCFG_ROOT_PATH/bumpkin.json.lock" "$@"
          else
            exit 1
          fi
        '')
      ];
      shellHook = ''
        export NIXCFG_ROOT_PATH=$(pwd)
        ${global.environmentShell}
        echo Shell setup complete!
      '';
    };
    release = pkgs.stdenv.mkDerivation {
      pname = "nixcfg-release";
      version = "${self.rev or (builtins.throw "Commita!")}";

      preferLocalBuild = true;

      dontUnpack = true;
      buildInputs = []
        ++ (with pkgs.custom; [ neovim ])
        # ++ (with pkgs.custom; [ firefox tixati emacs ])
        ++ (with pkgs.custom.vscode; [ common programming ])
        ++ (with self.nixosConfigurations; [
          riverwood.config.system.build.toplevel
          whiterun.config.system.build.toplevel
          # ivarstead.config.system.build.toplevel
        ])
        ++ (with self.homeConfigurations; [
          main.activationPackage
        ])
        ++ (with self.devShells.${system}; [
          (pkgs.writeShellScriptBin "s" "echo ${default.outPath}")
        ])
        # ++ (let
        #   flattenItems = items: if pkgs.lib.isDerivation items
        #     then items
        #     else if pkgs.lib.isAttrs items then pkgs.lib.flatten ((map (flattenItems) (builtins.attrValues items)))
        #     else []
        # ;
        # in map (item: (pkgs.writeShellScriptBin "source" "echo ${item}")) (flattenItems bumpkinInputs))
      ;
      installPhase = ''
        echo $version > $out
        for input in $buildInputs; do
          echo $input >> $out
        done
      '';
    };
  };
}

