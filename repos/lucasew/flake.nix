{
  description = "nixcfg";

  inputs = {
    bumpkin.url = "github:lucasew/bumpkin";
    bumpkin.inputs.nixpkgs.follows = "nixpkgs";

    cloud-savegame.url = "github:lucasew/cloud-savegame";
    cloud-savegame.flake = false;

    dotenv.url = "github:lucasew/dotenv";
    dotenv.flake = false;

    devenv.url = "github:cachix/devenv";
    devenv.flake = false;

    pocket2kindle.url = "github:lucasew/pocket2kindle";
    pocket2kindle.flake = false;

    send2kindle.url = "github:lucasew/send2kindle";
    send2kindle.flake = false;

    go-annotation.url = "github:lucasew/go-annotation";
    go-annotation.flake = false;

    ts-proxy.url = "github:lucasew/ts-proxy";
    ts-proxy.flake = false;

    nix-emacs.url = "github:nixosbrasil/nix-emacs";
    nix-emacs.flake = false;

    nix-option.url = "github:lucasew/nix-option";
    nix-option.flake = false;

    pytorrentsearch.url = "github:lucasew/pytorrentsearch";
    pytorrentsearch.flake = false;

    rio.url = "github:raphamorim/rio";
    rio.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";

    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    impermanence.url = "github:nix-community/impermanence";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nbr.url = "github:nixosbrasil/nixpkgs-brasil";
    nbr.inputs.nixpkgs.follows = "nixpkgs";
    nbr.inputs.flake-utils.follows = "flake-utils";

    nur.url = "github:nix-community/nur";

    nix-on-droid.url = "github:t184256/nix-on-droid";
    nix-on-droid.inputs.home-manager.follows = "home-manager";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode.url = "github:nixosbrasil/nix-vscode";
    nix-vscode.flake = false;

    home-manager.url = "home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # betterdiscord-addons.url = "github:mwittrien/BetterDiscordAddons?dir=Plugins";
    # betterdiscord-addons.flake = false;

    nix-requirefile.url = "github:lucasew/nix-requirefile";
    nix-requirefile.flake = false;

    nix-requirefile-data.url = "github:lucasew/nix-requirefile/data";
    nix-requirefile-data.flake = false;

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

    regex101.url = "github:lucasew/regex101";
    regex101.flake = false;

    # src-python-std2.url = "github:ms-jpq/std2/std";
    # src-python-std2.flake = false;

    # src-python-pynvim_pp.url = "github:ms-jpq/pynvim_pp/pp";
    # src-python-pynvim_pp.flake = false;
    src-cached-nix-shell.url = "github:xzfc/cached-nix-shell";
    src-cached-nix-shell.flake = false;
  };

  outputs =
    {
      self,
      bumpkin,
      nix-index-database,
      nixpkgs,
      home-manager,
      impermanence,
      nbr,
      nur,
      nixos-hardware,
      flake-utils,
      ...
    }@inputs:
      flake-utils.lib.eachSystem ["x86_64-linux"] (system:
    let
      bootstrapPkgs = import nixpkgs {
        inherit system;
        overlays = [ ]; # essential, infinite loop if not when using overlays
      };

      defaultNixpkgs = import ./nix/lib/patchNixpkgs.nix {
        inherit nixpkgs system bootstrapPkgs;
        patches = [ ];
      };

      pkgs = mkPkgs { inherit system; };

      mkPkgs =
        {
          nixpkgs ? defaultNixpkgs,
          config ? { },
          overlays ? [ ],
          disableOverlays ? false,
          system ? builtins.currentSystem,
        }:
        import nixpkgs {
          localSystem = system;
          config = config // {
            allowUnfree = true;
            nvidia.acceptLicense = true;
            android_sdk.accept_license = true;
            permittedInsecurePackages = [
              # "python-2.7.18.6"
              # "electron-18.1.0"
              # "electron-21.4.0"
              # "openssl-1.1.1u"
              # "openssl-1.1.1v"
              # "openssl-1.1.1w"
              "electron-25.9.0"
            ];
          };
          overlays =
            if disableOverlays then [ ] else (overlays ++ (builtins.attrValues self.outputs.overlays.${system}));
        };

      global = {
        username = "lucasew";
        email = "lucas59356@gmail.com";
        nodeIps = {
          riverwood = {
            ts = "100.107.51.95";
            zt = "192.168.69.2";
          };
          whiterun = {
            ts = "100.85.38.19";
            zt = "192.168.69.1";
          };
          phone = {
            ts = "100.76.88.29";
            zt = "192.168.69.4";
          };
        };
        selectedDesktopEnvironment = "i3";
        environmentShell = ''
          source ${self}/bin/source_me
          export NIX_PATH=nixpkgs=${defaultNixpkgs}:nixpkgs-overlays=$NIXCFG_ROOT_PATH/nix/compat/overlay.nix:home-manager=${home-manager}:nur=${nur}
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
        rust-overlay = final: prev: import "${inputs.rust-overlay}/rust-overlay.nix" final prev;
        zzzthis = import ./nix/overlay.nix self;
      };
      colors = inputs.nix-colors.colorschemes."ayu-dark" // {
        isDark = true;
      };
    in
    {
      # inherit (extraArgs) bumpkin;
      inherit global;
      inherit overlays;
      legacyPackages = pkgs;
      inherit self;

      formatter = pkgs.nixfmt-rfc-style;

      colors = colors // {
        colors = colors.palette;
      };

      homeConfigurations = pkgs.callPackage ./nix/homes {
        inherit extraArgs;
        nodes = {
          main = {
            modules = [ ./nix/homes/main ];
            inherit pkgs;
          };
        };
      };

      packages = {
        default = pkgs.writeShellScriptBin "default" ''
          ${global.environmentShell}
          "$@"
        '';

        deploy =
          let
            home = self.homeConfigurations.${system}.main.activationPackage;
            riverwood = self.nixosConfigurations.${system}.riverwood.config.system.build.toplevel;
            whiterun = self.nixosConfigurations.${system}.whiterun.config.system.build.toplevel;
          in
          pkgs.writeShellScriptBin "deploy" ''
             nix-copy-closure --to riverwood ${riverwood} ${home}
             nix-copy-closure --to whiterun ${whiterun} ${home}
             riverwood_cmd=boot
             whiterun_cmd=boot
             if [[ "$(realpath ${riverwood}/etc/.nixpkgs-used)" == "$(ssh riverwood realpath /etc/.nixpkgs-used)" ]]; then
               riverwood_cmd=switch
             fi
            if [[ "$(realpath ${whiterun}/etc/.nixpkgs-used)" == "$(ssh whiterun realpath /etc/.nixpkgs-used)" ]]; then
               whiterun_cmd=switch
             fi

             ssh -t riverwood ${home}/bin/home-manager-generation 
             ssh -t whiterun ${home}/bin/home-manager-generation 
             
             if [[ "${riverwood}" != "$(ssh riverwood realpath /run/current-system)" ]]; then
               ssh -t riverwood sudo ${riverwood}/bin/switch-to-configuration $riverwood_cmd
             else
               echo "INFO(riverwood): newly built generation results in the same path that is already running"
             fi

             if [[ "${whiterun}" != "$(ssh whiterun realpath /run/current-system)" ]]; then
               ssh -t whiterun sudo ${whiterun}/bin/switch-to-configuration $whiterun_cmd
             else
               echo "INFO(whiterun): newly built generation results in the same path that is already running"
             fi

          '';

        release = pkgs.stdenv.mkDerivation {
          pname = "nixcfg-release";
          version = "${self.rev or (builtins.throw "Commita!")}";

          preferLocalBuild = true;

          dontUnpack = true;
          buildInputs =
            [ ]
            # ++ (with pkgs.custom; [ neovim ])
            # ++ (with pkgs.custom; [ firefox tixati emacs ])
            # ++ (with pkgs.custom.vscode; [ common programming ])
            ++ (with self.nixosConfigurations.${system}; [
              riverwood.config.system.build.toplevel
              whiterun.config.system.build.toplevel
              # ivarstead.config.system.build.toplevel
            ])
            ++ (with self.homeConfigurations.${system}; [ main.activationPackage ])
          # ++ (with self.devShells.${system}; [
          #   (pkgs.writeShellScriptBin "s" "echo ${default.outPath}")
          # ])
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

      nixosConfigurations = pkgs.callPackage ./nix/nodes {
        inherit extraArgs;
        nodes = {
          ravenrock = {
            modules = [ ./nix/nodes/ravenrock ];
            inherit pkgs;
          };
          riverwood = {
            modules = [ ./nix/nodes/riverwood ];
            inherit pkgs;
          };
          whiterun = {
            modules = [ ./nix/nodes/whiterun ];
            inherit pkgs;
          };
          recovery = {
            modules = [ ./nix/nodes/recovery ];
            inherit pkgs;
          };
          demo = {
            modules = [ ./nix/nodes/demo ];
            inherit pkgs;
          };
        };
      };

      nixOnDroidConfigurations = pkgs.callPackage ./nix/nixOnDroidConfigurations {
        inherit extraArgs mkPkgs;
        nodes = {
          default = {
            modules = [ ./nix/nixOnDroid/default ];
            system = "aarch64-linux";
          };
        };
      };

      devShells.default = pkgs.mkShell {
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
    });
}
