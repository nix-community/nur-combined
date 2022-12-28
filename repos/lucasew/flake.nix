{
  description = "nixcfg";

  inputs = {
    # preview: nix flake metadata
    borderless-browser.url =  "github:lucasew/borderless-browser.nix";
    borderless-browser.inputs.nixpkgs.follows = "nixpkgs";

    blender-bin.url =  "blender-bin";
    blender-bin.inputs.nixpkgs.follows = "nixpkgs";

    climod.url = "github:nixosbrasil/climod";
    climod.flake = false;

    comma.url =  "github:Shopify/comma";
    comma.flake = false;

    dotenv.url =  "github:lucasew/dotenv";
    dotenv.flake = false;

    erosanix.url = "github:emmanuelrosa/erosanix";
    erosanix.inputs.nixpkgs.follows = "nixpkgs";
    erosanix.inputs.flake-compat.follows = "flake-compat";

    flake-utils.url =  "flake-utils";

    flake-compat.url =  "github:edolstra/flake-compat";
    flake-compat.flake = false;

    home-manager.url =  "home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.utils.follows = "flake-utils";

    impermanence.url =  "github:nix-community/impermanence";

    mach-nix.url =  "mach-nix";
    mach-nix.inputs.nixpkgs.follows = "nixpkgs";
    mach-nix.inputs.flake-utils.follows = "flake-utils";

    nix-colors.url = "github:Misterio77/nix-colors";

    nix-vscode.url =  "github:lucasew/nix-vscode";
    nix-vscode.flake = false;

    nix-emacs.url =  "github:nixosbrasil/nix-emacs";
    nix-emacs.flake = false;

    nix-option.url =  "github:lucasew/nix-option";
    nix-option.flake = false;

    nix-on-droid.url =  "github:t184256/nix-on-droid/master";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.inputs.home-manager.follows = "home-manager";

    nixgram.url =  "github:lucasew/nixgram/master";
    nixgram.flake = false;

    nixos-hardware.url =  "nixos-hardware";

    nixos-generators.url =  "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-unstable.url =  "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-staging.url =  "github:NixOS/nixpkgs/staging";
    nixpkgs.url =  "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-whiterun.url =  "github:NixOS/nixpkgs/5b18bcaf8121d01897855ae0ef373f9df5d78300";

    nur.url =  "nur";

    pocket2kindle.url =  "github:lucasew/pocket2kindle";
    pocket2kindle.flake = false;

    pollymc.url = "github:fn2006/PollyMC";
    pollymc.inputs.flake-compat.follows = "flake-compat";

    redial_proxy.url =  "github:lucasew/redial_proxy";
    redial_proxy.flake = false;

    rust-overlay.url =  "github:oxalica/rust-overlay";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    send2kindle.url =  "github:lucasew/send2kindle";
    send2kindle.flake = false;

    simple-dashboard.url = "github:lucasew/simple-dashboard";
    simple-dashboard.flake = false;

    nbr.url = "github:nixosbrasil/nixpkgs-brasil";
  };

  outputs = {
      self
    , borderless-browser
    , dotenv
    , flake-utils
    , home-manager
    , nix-colors
    , nix-on-droid
    , nix-vscode
    , nixgram
    , nixos-hardware
    , nixpkgs
    , nur
    , pocket2kindle
    , redial_proxy
    , pollymc
    , ...
  }@inputs:
  let
    system = builtins.currentSystem or "x86_64-linux";
    inherit (builtins) replaceStrings toFile trace readFile concatStringsSep;
    inherit (home-manager.lib) homeManagerConfiguration;

        mkPkgs = {
          nixpkgs ? inputs.nixpkgs
        , config ? {}
        , overlays ? []
        , system ? builtins.currentSystem
        }: import nixpkgs {
          config = config // {
            allowUnfree = true;
            permittedInsecurePackages = [
              "qtwebkit-5.212.0-alpha4"
            ];
          };
          overlays = overlays ++ (builtins.attrValues self.outputs.overlays);
          inherit system;
        };
        pkgs = mkPkgs { inherit system; };

        global = rec {
          username = "lucasew";
          email = "lucas59356@gmail.com";
          selectedDesktopEnvironment = "i3";
          rootPath = "/home/${username}/.dotfiles";
          rootPathNix = "${rootPath}";
          environmentShell = with pkgs; ''
            export NIXPKGS_ALLOW_UNFREE=1
            if [[ ! -v NIXCFG_ROOT_PATH ]]; then
              NIXCFG_ROOT_PATH="$(pwd)"
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
            export NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-overlays=$NIXCFG_ROOT_PATH/compat/overlay.nix:home-manager=${home-manager}:nur=${nur}
          '';
        };

        extraArgs = {
          inherit self;
          inherit global;
          cfg = throw "your past self made a trap for non compliant code after a migration you did, now follow the stacktrace and go fix it";
        };

      overlays = {
        home-manager = import (home-manager + "/overlay.nix");
        borderless-browser = borderless-browser.overlays.default;
        blender-bin = inputs.blender-bin.overlays.default;
        rust-overlay = inputs.rust-overlay.overlays.default;
        pollymc = inputs.pollymc.overlay;
        this = import ./overlay.nix self;
        unstable = final: prev: {
          unstable = mkPkgs {
            nixpkgs = inputs.nixpkgs-unstable;
            inherit system;
          };
        };
      };
  in {
    inherit global;
    inherit overlays;
    inherit pkgs;
    inherit self;

    colors = inputs.nix-colors.colorSchemes."classic-dark";

    homeConfigurations = {
      main = homeManagerConfiguration {
        extraSpecialArgs = extraArgs // {
          pkgsPath = pkgs.path;
        };
        modules = [
          ./homes/main/default.nix
        ];
        inherit pkgs;
      };
    };

    nixosConfigurations = let
      nixosConf = {
          mainModule
        , nixpkgs ? inputs.nixpkgs
        , extraModules ? []
        , system ? "x86_64-linux"
      }:
      let
        revModule = {pkgs, ...}: let
          rev = if (self ? rev) then 
              trace "detected flake hash: ${self.rev}" self.rev
            else
              trace "flake hash not detected!" null
          ;
        in {
          system.configurationRevision = rev;
          system.nixos.label = "lucasew:nixcfg-${rev}";
        };
        source = {
          pkgs = mkPkgs {
            inherit nixpkgs system;
          };
          inherit system;
          modules = [
            revModule
            (mainModule)
          ] ++ extraModules;
          specialArgs = extraArgs;
        };
      in
        nixpkgs.lib.nixosSystem source;
    in {
      ivarstead = nixosConf {
        mainModule = ./nodes/ivarstead/default.nix;
      };
      riverwood = nixosConf {
        mainModule = ./nodes/riverwood/default.nix;
      };
      whiterun = nixosConf {
        mainModule = ./nodes/whiterun/default.nix;
        # nixpkgs = inputs.nixpkgs-whiterun;
      };
      demo = nixosConf {
        mainModule = ./nodes/demo/default.nix;
      };
      # bootstrap = nixosConf {
      #   mainModule = ./nodes/bootstrap/default.nix;
      # };
    };
    nixOnDroidConfigurations = let
      nixOnDroidConf = mainModule:
      import "${nix-on-droid}/modules" {
        config = {
          _module.args = extraArgs;
          home-manager.config._module.args = extraArgs;
          imports = [
            mainModule
          ];
        };
        pkgs = mkPkgs {
          overlays = (import "${nix-on-droid}/overlays");
        };
        home-manager = import home-manager {};
        isFlake = true;
      };
    in {
      xiaomi = nixOnDroidConf ./nodes/xiaomi/default.nix;
    };

    devShells.${system}.default = pkgs.mkShell {
      name = "nixcfg-shell";
      buildInputs = with pkgs; [
        ctl
        ansible
      ];
      shellHook = ''
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
        ++ (with pkgs.custom; [ neovim emacs firefox polybar tixati ])
        ++ (with pkgs.custom.vscode; [ common programming ])
        ++ (with self.nixosConfigurations; [
          riverwood.config.system.build.toplevel
          whiterun.config.system.build.toplevel
          # ivarstead.config.system.build.toplevel
        ])
        ++ (with self.homeConfigurations; [
          main.activationPackage
        ])
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

