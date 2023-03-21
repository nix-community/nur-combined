{
  description = "nixcfg";

  inputs = {
    bumpkin.url = "github:lucasew/bumpkin";
  };

  outputs = {
      self
    , bumpkin
  }:
  let
    defaultNixpkgs = unpackedInputs.nixpkgs.unstable.overrideAttrs (old: {
      patches = [
      ];
    });

    inherit (builtins) replaceStrings toFile trace readFile concatStringsSep mapAttrs;

    inherit (let
      bootstrapPkgs = mkPkgs {
        inherit system;
        nixpkgs = bumpkin.inputs.nixpkgs.outPath;
        disableOverlays = true;
      };
      bumpkinPkg = bootstrapPkgs.callPackage bumpkin.outPath {};
      inputs = bumpkinPkg.loadBumpkin {
        inputFile = ./bumpkin.json;
        outputFile = ./bumpkin.json.lock;
      };
      unpackedInputs = (bootstrapPkgs.callPackage ./lib/unpackRecursive.nix {}) inputs;
    in {inherit inputs unpackedInputs;}) inputs unpackedInputs;


    pkgs = mkPkgs { inherit system; nixpkgs = defaultNixpkgs; };

    importFlake = import ./lib/importFlake.nix;
    mapAttrValues = pkgs.callPackage ./lib/mapAttrValues.nix {};

    system = builtins.currentSystem or "x86_64-linux";

    mkPkgs = {
      nixpkgs #? defaultNixpkgs
    , config ? {}
    , overlays ? []
    , disableOverlays ? false
    , system ? builtins.currentSystem
    }: import "${nixpkgs}/pkgs/top-level" {
      localSystem = system;
      config = config // {
        allowUnfree = true;
        permittedInsecurePackages = [
            "python-2.7.18.6"
            "electron-18.1.0"
        ];
      };
      overlays = if disableOverlays then [] else (overlays ++ (builtins.attrValues self.outputs.overlays));
      inherit system;
    };

    global = rec {
      username = "lucasew";
      email = "lucas59356@gmail.com";
      selectedDesktopEnvironment = "i3";
      rootPath = "/home/${username}/.dotfiles";
      rootPathNix = "${rootPath}";
      environmentShell = with pkgs; ''
        export NIXPKGS_ALLOW_UNFREE=1
        if [[ ! -v NIXCFG_ROOT_PATH ]]; then
          export NIXCFG_ROOT_PATH="$(pwd)"
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
        export NIX_PATH=nixpkgs=${defaultNixpkgs}:nixpkgs-overlays=$NIXCFG_ROOT_PATH/compat/overlay.nix:home-manager=${home-manager}:nur=${unpackedInputs.nur}
      '';
    };

    extraArgs = {
      inherit self;
      inherit global;
      cfg = throw "your past self made a trap for non compliant code after a migration you did, now follow the stacktrace and go fix it";
      inherit unpackedInputs;
    };

    overlays = {
      nix-requirefile = import "${unpackedInputs.nix-requirefile.lib}/overlay.nix";
      borderless-browser = import "${unpackedInputs.borderless-browser}/overlay.nix";
      rust-overlay = import "${unpackedInputs.rust-overlay}/rust-overlay.nix";
      zzzthis = import ./overlay.nix self;
    };
    nix-colors = import "${unpackedInputs.nix-colors}" { inherit (unpackedInputs) base16-schemes nixpkgs-lib; };
  in {
    test = {
      inherit self;
    };
    bumpkin = {
      inherit inputs;
      inherit unpackedInputs;
      flakedInputs = {
        inherit nix-colors;
      };
    };
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
      }: import "${unpackedInputs.home-manager}/modules" {
        inherit pkgs;
        extraSpecialArgs = extraArgs // extraSpecialArgs // { inherit pkgs; };
        configuration = {...}: {
          imports = modules;
        };
      };
    in mapAttrValues hmConf {
      main = { modules = [ ./homes/main ]; inherit pkgs; };
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
      ivarstead = { modules = [ ./nodes/ivarstead ]; inherit pkgs; };
      riverwood = { modules = [ ./nodes/riverwood ]; inherit pkgs; };
      whiterun  = { modules = [ ./nodes/whiterun  ]; inherit pkgs; };
      demo      = { modules = [ ./nodes/demo      ]; inherit pkgs; };
    };

    nixOnDroidConfigurations = let
      nixOnDroidConf = mainModule:
      import "${unpackedInputs.nix-on-droid}/modules" {
        config = {
          _module.args = extraArgs;
          home-manager.config._module.args = extraArgs;
          imports = [
            mainModule
          ];
        };
        pkgs = mkPkgs {
          overlays = (import "${unpackedInputs.nix-on-droid}/overlays");
        };
        home-manager = import unpackedInputs.home-manager {};
        isFlake = true;
      };
    in mapAttrValues nixOnDroidConf {
      xiaomi = ./nodes/xiaomi/default.nix;
    };

    devShells.${system}.default = pkgs.mkShell {
      name = "nixcfg-shell";
      buildInputs = with pkgs; [
        ctl
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
        in map (item: (pkgs.writeShellScriptBin "source" "echo ${item}")) (flattenItems inputs))
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

