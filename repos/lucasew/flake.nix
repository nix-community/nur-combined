{
  description = "nixcfg";

  inputs = {
    bumpkin.url = "github:lucasew/bumpkin";

    # preview: nix flake metadata

  };

  outputs = {
      self
    , bumpkin
  }:
  let
    system = builtins.currentSystem or "x86_64-linux";
    inputs = bumpkin.packages.x86_64-linux.default.loadBumpkin {
      inputFile = ./bumpkin.json;
      outputFile = ./bumpkin.json.lock;
    };
    inherit (builtins.mapAttrs import inputs) borderless-browser home-manager nix-on-droid;

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
                "python-2.7.18.6"
                "electron-18.1.0"
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
        pkgs = mkPkgs {
          inherit nixpkgs system;
        };
        source = {
          inherit system pkgs;
          inherit (pkgs) lib;
          modules = [
            (mainModule)
          ] ++ extraModules;
          specialArgs = extraArgs;
        };
      in import "${nixpkgs}/nixos/lib/eval-config.nix" source;
    in {
      ivarstead = nixosConf {
        mainModule = ./nodes/ivarstead/default.nix;
      };
      riverwood = nixosConf {
        mainModule = ./nodes/riverwood/default.nix;
        nixpkgs = inputs.nixpkgs-unstable;
      };
      whiterun = nixosConf {
        mainModule = ./nodes/whiterun/default.nix;
        nixpkgs = inputs.nixpkgs-unstable;
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
        bumpkin
        (writeShellScriptBin "bumpkin-bump" ''
          if [ -v "$NIXCFG_ROOT_PATH" ]; then
              bumpkin eval -i "$NIXCFG_ROOT_PATH/bumpkin.json" -o "$NIXCFG_ROOT_PATH/bumpkin.json.lock"
          else
            exit 1
          fi
        '')
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

