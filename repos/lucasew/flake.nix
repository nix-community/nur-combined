{
  description = "nixcfg";

  inputs = {
    bumpkin.url = "github:lucasew/bumpkin";
    bumpkin.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";

    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    impermanence.url = "github:nix-community/impermanence";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nbr.url = "github:nixosbrasil/nixpkgs-brasil";
    nbr.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/nur";

    home-manager.url = "home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
  }:
  let
    inherit (builtins) replaceStrings toFile trace readFile concatStringsSep mapAttrs length;

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

    inherit (let
      bumpkinPkg = bootstrapPkgs.callPackage bumpkin {};
      bumpkinInputs = bumpkinPkg.loadBumpkin {
        inputFile = ./bumpkin.json;
        outputFile = ./bumpkin.json.lock;
      };
      bumpkinUnpackedInputs = (bootstrapPkgs.callPackage ./nix/lib/unpackRecursive.nix {}) bumpkinInputs;
    in {inherit bumpkinInputs bumpkinUnpackedInputs;}) bumpkinInputs bumpkinUnpackedInputs;

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
        export NIX_PATH=nixpkgs=${defaultNixpkgs}:nixpkgs-overlays=$NIXCFG_ROOT_PATH/nix/compat/overlay.nix:home-manager=${home-manager}:nur=${bumpkinUnpackedInputs.nur}
      '';
    };

    extraArgs = {
      inherit self;
      inherit global;
      cfg = throw "your past self made a trap for non compliant code after a migration you did, now follow the stacktrace and go fix it";
      bumpkin = {
        inputs = bumpkinInputs;
        unpacked = bumpkinUnpackedInputs;
      };
    };

    overlays = {
      nix-requirefile = import "${extraArgs.bumpkin.unpacked.nix-requirefile.lib}/overlay.nix";
      borderless-browser = import "${extraArgs.bumpkin.unpacked.borderless-browser}/overlay.nix";
      rust-overlay = import "${extraArgs.bumpkin.unpacked.rust-overlay}/rust-overlay.nix";
      zzzthis = import ./nix/overlay.nix self;
    };
    nix-colors = import "${extraArgs.bumpkin.unpacked.nix-colors}" { inherit (extraArgs.bumpkin.unpacked) base16-schemes nixpkgs-lib; };
  in {
    test = {
      inherit self;
    };
    inherit (extraArgs) bumpkin;
    inherit global;
    inherit overlays;
    inherit pkgs;
    inherit self;

    colors = nix-colors.colorSchemes."classic-dark";

    homeConfigurations = let
        hmConf = {
          modules ? []
        , pkgs
        , extraSpecialArgs ? {}
      }: import "${home-manager}/modules" {
        inherit pkgs;
        extraSpecialArgs = extraArgs // extraSpecialArgs // { inherit pkgs; };
        configuration = {...}: {
          imports = modules;
        };
      };
    in mapAttrValues hmConf {
      main = { modules = [ ./nix/homes/main ]; inherit pkgs; };
    };

    nixosConfigurations = let
      nixosConf = {
          modules ? []
        , extraSpecialArgs ? {}
        , pkgs
        , system ? pkgs.system
      }: import "${pkgs.path}/nixos/lib/eval-config.nix" {
        specialArgs = extraSpecialArgs // extraArgs;
        inherit system pkgs modules;
      };
    in mapAttrValues nixosConf {
      ravenrock = { modules = [ ./nix/nodes/ravenrock ]; inherit pkgs; };
      riverwood = { modules = [ ./nix/nodes/riverwood ]; inherit pkgs; };
      whiterun  = { modules = [ ./nix/nodes/whiterun  ]; inherit pkgs; };
      demo      = { modules = [ ./nix/nodes/demo      ]; inherit pkgs; };
    };

    nixOnDroidConfigurations = let
      nixOnDroidConf = mainModule:
      import "${bumpkinUnpackedInputs.nix-on-droid}/modules" {
        config = {
          _module.args = extraArgs;
          home-manager.config._module.args = extraArgs;
          imports = [
            mainModule
          ];
        };
        pkgs = mkPkgs {
          overlays = (import "${bumpkinUnpackedInputs.nix-on-droid}/overlays");
        };
        home-manager = import bumpkinUnpackedInputs.home-manager {};
        isFlake = true;
      };
    in mapAttrValues nixOnDroidConf {
      xiaomi = ./nix/nodes/xiaomi/default.nix;
    };

    devShells.${system}.default = pkgs.mkShell {
      name = "nixcfg-shell";
      buildInputs = with pkgs; [
        ctl
        pyinfra
        ansible
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
        ++ (with pkgs.custom; [ neovim emacs firefox tixati ])
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
        ++ (let
          flattenItems = items: if pkgs.lib.isDerivation items
            then items
            else if pkgs.lib.isAttrs items then pkgs.lib.flatten ((map (flattenItems) (builtins.attrValues items)))
            else []
        ;
        in map (item: (pkgs.writeShellScriptBin "source" "echo ${item}")) (flattenItems bumpkinInputs))
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

