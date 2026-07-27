{
  description = "nixcfg";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://lucasew-personal.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "lucasew-personal.cachix.org-1:sGVvGjt2TiYjRacwboM4dbxjX036rsZwjgDG+NKgGe8="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    cloud-savegame.url = "github:lucasew/cloud-savegame";
    cloud-savegame.flake = false;

    nix-index-database.url = "github:Mic92/nix-index-database";


    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nbr.url = "github:nixosbrasil/nixpkgs-brasil";
    nbr.inputs.nixpkgs.follows = "nixpkgs";
    nbr.inputs.flake-utils.follows = "flake-utils";

    nur.url = "github:nix-community/nur";

    nix-colors.url = "github:Misterio77/nix-colors";
    nix-colors.inputs.nixpkgs-lib.follows = "nixpkgs-lib";

    flake-utils.url = "github:numtide/flake-utils";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    telegram-sendmail.url = "github:lucasew/telegram-sendmail";
    telegram-sendmail.flake = false;

    phpelo.url = "github:lucasew/phpelo";
    phpelo.flake = false;
  };

  outputs =
    {
      self,
      nix-index-database,
      nixpkgs,
      nbr,
      nur,
      nixos-hardware,
      flake-utils,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
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
            permittedInsecurePackages = [ ];
          };
          overlays =
            if disableOverlays then [ ] else (overlays ++ (builtins.attrValues self.outputs.overlays));
        };
      global = {
        username = "lucasew";
        email = "lucas59356@gmail.com";
        selectedDesktopEnvironment = "i3";
        environmentShell = ''
          source ${self}/bin/source_me
        '';
      };

      extraArgs = {
        inherit self;
        inherit global;
        cfg = throw "your past self made a trap for non compliant code after a migration you did, now follow the stacktrace and go fix it";
      };
    in
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = mkPkgs { inherit system; };
      in
      {
        inherit global self;
        legacyPackages = pkgs;

        formatter = pkgs.nixfmt-rfc-style;

        packages = {
          default = pkgs.writeShellScriptBin "default" ''
            ${global.environmentShell}
            "$@"
          '';

          deploy = pkgs.writeShellScriptBin "deploy" ''
            exec workspaced utils nix deploy "$@"
          '';

          teste-impure =
            pkgs.runCommand "teste"
              {
                __impure = true;
                nativeBuildInputs = with pkgs; [
                  cacert
                  curl
                ];
              }
              ''
                # TODO: find a way to mount the sops secret folder inside
                ls -a /
                echo foi
                ls -a /etc
                curl -L https://google.com
                date > $out
              '';

          release = pkgs.stdenv.mkDerivation {
            pname = "nixcfg-release";
            version = "${toString self.lastModified}-${self.inputs.nixpkgs.rev}";
            # version = "${self.rev or (builtins.trace "nixpkgs_${nixpkgs.rev}" "Commita!")}";

            preferLocalBuild = true;

            dontUnpack = true;
            buildInputs =
              [ ]
              # ++ (with pkgs.custom; [ neovim ])
              # ++ (with pkgs.custom; [ firefox tixati emacs ])
              # ++ (with pkgs.custom.vscode; [ common programming ])
              ++ (with self.nixosConfigurations; [
                riverwood.config.system.build.toplevel
                whiterun.config.system.build.toplevel
                # ivarstead.config.system.build.toplevel
              ])
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
        devShells.default = pkgs.mkShell {
          name = "nixcfg-shell";
          buildInputs = with pkgs; [
            # ctl # missing
          ];
          shellHook = ''
            export NIXCFG_ROOT_PATH=$(pwd)
            ${global.environmentShell}
            echo Shell setup complete!
          '';
        };
      }
    )
    // {
      lib = {
        inherit mkPkgs;
      };
      overlays = {
        # nix-requirefile = import "${inputs.nix-requirefile}/overlay.nix";
        zzzthis = import ./nix/overlay.nix self;
      };
      colors =
        let
          scheme = inputs.nix-colors.colorschemes."darkviolet";
        in
        scheme
        // {
          isDark = true;
          colors = scheme.palette;
        };

      nixosConfigurations = import ./nix/nodes {
        inherit extraArgs system;
        path = inputs.nixpkgs;
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
          atomicpi = {
            modules = [ ./nix/nodes/atomicpi ];
            inherit pkgs;
          };
          recovery = {
            modules = [ ./nix/nodes/recovery ];
            inherit pkgs;
          };
        };
      };

      containers = pkgs.callPackage ./nix/containers { inherit self; };
    };
}
