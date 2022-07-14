{
  description = "nixcfg";

  inputs = {
    borderless-browser = {url =  "github:lucasew/borderless-browser.nix";           inputs.nixpkgs.follows = "nixpkgs"; };
    blender-bin =        {url =  "blender-bin";                                     inputs.nixpkgs.follows = "nixpkgs"; };
    comma =              {url =  "github:Shopify/comma";                            flake = false;                      };
    dotenv =             {url =  "github:lucasew/dotenv";                           flake = false;                      };
    flake-utils =        {url =  "flake-utils";                                                                         };
    home-manager =       {url =  "home-manager/release-22.05";                      inputs.nixpkgs.follows = "nixpkgs"; };
    impermanence =       {url =  "github:nix-community/impermanence";               inputs.nixpkgs.follows = "nixpkgs"; };
    mach-nix =           {url =  "mach-nix";                                        inputs.nixpkgs.follows = "nixpkgs"; };
    nix-ld =             {url =  "github:Mic92/nix-ld";                             inputs.nixpkgs.follows = "nixpkgs"; };
    nix-vscode =         {url =  "github:lucasew/nix-vscode";                       flake = false;                      };
    nix-emacs =          {url =  "github:nixosbrasil/nix-emacs";                    flake = false;                      };
    nix-option =         {url =  "github:lucasew/nix-option";                       flake = false;                      };
    nix-on-droid =       {url =  "github:t184256/nix-on-droid/master";              inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; inputs.home-manager.follows = "home-manager"; };
    nixgram =            {url =  "github:lucasew/nixgram/master";                   flake = false;                      };
    nixos-hardware =     {url =  "nixos-hardware";                                  inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-generators =   {url =  "github:nix-community/nixos-generators";           inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs-stable =     {url =  "github:NixOS/nixpkgs/nixos-22.05";                                                    };
    nixpkgs        =     {url =  "github:NixOS/nixpkgs/nixos-22.05";                                                    };
    nur =                {url =  "nur";                                             inputs.nixpkgs.follows = "nixpkgs"; };
    pocket2kindle =      {url =  "github:lucasew/pocket2kindle";                    flake = false;                      };
    redial_proxy =       {url =  "github:lucasew/redial_proxy";                     flake = false;                      };
    rust-overlay =       {url =  "github:oxalica/rust-overlay"; inputs.flake-utils.follows = "flake-utils"; inputs.nixpkgs.follows = "nixpkgs"; };
    send2kindle =        {url =  "github:lucasew/send2kindle";                      flake = false;                      };
  };

  outputs = { self, flake-utils, ... }@inputs:
  let
    system = builtins.currentSystem or "x86_64-linux";
    inherit (inputs)
    borderless-browser
    dotenv
    flake-utils
    home-manager
    nix-ld
    nix-vscode
    nixgram
    nixpkgs
    nixos-hardware
    nix-on-droid
    nur
    pocket2kindle
    redial_proxy
    ;
    inherit (builtins) replaceStrings toFile trace readFile concatStringsSep;
    inherit (home-manager.lib) homeManagerConfiguration;

        mkPkgs = { 
          nixpkgs ? inputs.nixpkgs
        , config ? {}
        , overlays ? []
        , system ? builtins.currentSystem
        }: import nixpkgs {
          config = config // { allowUnfree = true; };
          overlays = overlays ++ (builtins.attrValues self.outputs.overlays);
          inherit system;
        };
        pkgs = mkPkgs { inherit system; };

        global = rec {
          username = "lucasew";
          email = "lucas59356@gmail.com";
          selectedDesktopEnvironment = "xfce_i3";
          rootPath = "/home/${username}/.dotfiles";
          rootPathNix = "${rootPath}";
          wallpaper = ./wall.jpg;
          system = throw "usa o system do flake!";
          environmentShell = with pkgs; ''
            export NIXPKGS_ALLOW_UNFREE=1
            export NIXCFG_ROOT_PATH="$HOME/.dotfiles"
            export NIX_LD="$(cat "${stdenv.cc.outPath}/nix-support/dynamic-linker")"
            export NIX_LD_LIBRARY_PATH=${lib.makeLibraryPath [
              stdenv.cc.cc
            ]}
            function nix-repl {
              nix repl "$NIXCFG_ROOT_PATH/repl.nix" "$@"
            }
            export LUA_PATH="${concatStringsSep ";" [
              ''$(realpath ${fennel}/share/lua/*)/?.lua''
              "$NIXCFG_ROOT_PATH/scripts/?.lua"
              "$NIXCFG_ROOT_PATH/scripts/?/index.lua"
            ]}"
            export PATH="${concatStringsSep ":" [
              "$PATH"
              "$NIXCFG_ROOT_PATH/scripts/bin"
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
        this = import ./overlay.nix self;
        stable = final: prev: {
          stable = mkPkgs {
            nixpkgs = inputs.nixpkgs-stable;
            inherit system;
          };
        };
      };
  in {
    inherit global;
    inherit overlays;
        # packages = pkgs;

    homeConfigurations = let 
      hmConf = source: homeManagerConfiguration (source // {
        extraSpecialArgs = extraArgs;
        inherit pkgs;
      });
    in {
      main = hmConf {
        configuration = import ./homes/main/default.nix;
        homeDirectory = "/home/${global.username}";
        inherit (global) system username;
      };
    };

    nixosConfigurations = let
      nixosConf = {
        mainModule,
        extraModules ? [],
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
          inherit pkgs system;
          modules = [
            revModule
            (mainModule)
          ] ++ extraModules;
          specialArgs = extraArgs;
        };
        eval = import "${nixpkgs}/nixos/lib/eval-config.nix";
        override = mySource: fn: let
          sourceProcessed = mySource // (fn mySource);
          evaluated = eval sourceProcessed;
        in evaluated // {
          source = sourceProcessed;
          override = override sourceProcessed;
        };
      in override source (v: {});
    in {
      vps = nixosConf {
        mainModule = ./nodes/vps/default.nix;
      };
      acer-nix = nixosConf {
        mainModule = ./nodes/acer-nix/default.nix;
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
      buildInputs = [];
      shellHook = ''
        ${global.environmentShell}
        echo Shell setup complete!
      '';
    };
    release = pkgs.stdenv.mkDerivation {
      pname = "nixcfg-release";
      version = "${self.rev or (builtins.throw "Commita!")}";

      dontUnpack = true;
      buildInputs = []
        ++ (with pkgs.custom; [ neovim emacs firefox polybar tixati ])
        ++ (with pkgs.custom.vscode; [ common programming ])
        ++ (with self.nixosConfigurations; [
          acer-nix.config.system.build.toplevel
          vps.config.system.build.toplevel
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
  # packages = pkgs;
}

