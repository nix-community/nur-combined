{
  description = "A flake for building my NUR packages";

  inputs = {
    home-manager. uri = "github:dguibert/home-manager/pu";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hydra.uri = "github:dguibert/hydra/pu";
    hydra.inputs.nix.follows = "nix";
    hydra.inputs.nixpkgs.follows = "nixpkgs";

    nixops.uri = "github:dguibert/nixops/pu";
    nixops.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.uri = "github:dguibert/nixpkgs/pu";

    nix.uri = "github:dguibert/nix/pu";
    nix.inputs.nixpkgs.follows = "nixpkgs";

    nur_dguibert.uri = "github:dguibert/nur-packages/pu";
    nur_dguibert.inputs.nix.follows = "nix";
    #nur_dguibert_envs.uri= "github:dguibert/nur-packages/pu?dir=envs";
    #nur_dguibert_envs.uri= "/home/dguibert/nur-packages?dir=envs";
    terranix = {
      uri = "github:mrVanDalo/terranix";
      flake = false;
    };
    #"nixos-18.03".uri   = "github:nixos/nixpkgs-channels/nixos-18.03";
    #"nixos-18.09".uri   = "github:nixos/nixpkgs-channels/nixos-18.09";
    #"nixos-19.03".uri   = "github:nixos/nixpkgs-channels/nixos-19.03";
    base16-nix = {
      uri = "github:atpotts/base16-nix";
      flake = false;
    };
    NUR = {
      uri = "github:nix-community/NUR";
      flake = false;
    };
    gitignore = {
      uri = "github:hercules-ci/gitignore";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nur_dguibert,
    base16-nix,
    NUR,
    gitignore,
    home-manager,
    terranix,
    hydra,
    nix,
    nixops,
  } @ flakes: let
    systems = ["aarch64-linux"];

    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

    # Memoize nixpkgs for different platforms for efficiency.
    defaultPkgsFor = forAllSystems (
      system:
        import nixpkgs {
          inherit system;
          overlays = [
            overlays.default
            nix.overlay
            (final: prev: {
              nixStore = "/ccc/scratch/cont003/bull/guibertd/nix";
            })
          ];
          config.allowUnfree = true;
        }
    );
    nixpkgsFor = forAllSystems (
      system:
        import nixpkgs {
          inherit system;
          overlays = [
            nix.overlay
            overlays.default
            self.overlay
          ];
          config.allowUnfree = true;
        }
    );

    overlays = import ../../overlays;
  in rec {
    overlay = import ./inti-overlay.nix;

    devShell.aarch64-linux = with defaultPkgsFor.aarch64-linux;
      mkShell rec {
        name = "nix-${builtins.replaceStrings ["/"] ["-"] nixStore}";
        ENVRC = "nix-${builtins.replaceStrings ["/"] ["-"] nixStore}";
        buildInputs = [defaultPkgsFor.aarch64-linux.nix jq];
        shellHook = ''
          export XDG_CACHE_HOME=$HOME/.cache/${name}
          unset NIX_STORE NIX_REMOTE
          unset TMP TMPDIR TEMPDIR TEMP
          NIX_PATH=
          ${lib.concatMapStrings (f: ''
            NIX_PATH+=:${toString f}=${toString flakes.${f}}
          '') (builtins.attrNames flakes)}
          export NIX_PATH

        '';
      };

    packages = forAllSystems (system: {
      nix = nixpkgsFor.${system}.nix;
      inherit (nixpkgsFor.${system}) git getpwuid;
    });

    defaultPackage = forAllSystems (system: self.packages.${system}.nix);
  };
}
