{
  description = "NUR packages of @nagy";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  # Outputs are assembled with flake-parts, same as the flakes below.
  inputs.flake-parts = {
    url = "github:hercules-ci/flake-parts";
    inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    # One nixpkgs closure, no duplicates.
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Full NUR closure.  Flake callers get it without a NIX_PATH lookup.
  inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  # Plain source tree, not a flake.  modules/emacs.nix imports it as an
  # overlay with `import inputs.emacs-overlay`.  Tracks upstream master;
  # flake.lock pins the revision.
  inputs.emacs-overlay = {
    url = "github:nix-community/emacs-overlay";
    flake = false;
  };

  inputs.jsonrpc-httpproxy = {
    url = "github:nagy/jsonrpc-httpproxy";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  # Private dotfiles tree.  my-build-env needs it, and the tree is not a
  # flake, so it arrives as a plain source path.
  inputs.dot = {
    url = "github:nagy/dotfiles";
    flake = false;
  };

  # Inputs that modules used to fetch with builtins.getFlake.  Pinning them
  # here keeps evaluation offline and lets the modules get one nixpkgs.
  inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.bruvtab = {
    url = "github:pschmitt/bruvtab";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-bruvtab = {
    url = "github:nagy/emacs-bruvtab";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-buffer-url = {
    url = "github:nagy/emacs-buffer-url";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-git-bug = {
    url = "github:nagy/emacs-git-bug";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-openstack-modes = {
    url = "github:nagy/emacs-openstack-modes";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-gitlab-modes = {
    url = "github:nagy/emacs-gitlab-modes";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-network-modes = {
    url = "github:nagy/emacs-network-modes";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.org-jxl-images = {
    url = "github:nagy/org-jxl-images.el";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.yublin = {
    url = "github:nagy/yublin.el";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.go-mod-ts-extras-mode = {
    url = "github:nagy/go-mod-ts-extras-mode";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.gguf = {
    url = "github:nagy/gguf.el";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.crate = {
    url = "github:nagy/crate.el";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.derivation = {
    url = "github:nagy/derivation.el";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.toml-ts-cargo-mode = {
    url = "github:nagy/toml-ts-cargo-mode";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-ron-ts-mode = {
    url = "github:nagy/emacs-ron-ts-mode";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-openrpc-mode = {
    url = "github:nagy/emacs-openrpc-mode";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-ipfs-modes = {
    url = "github:nagy/emacs-ipfs-modes";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-map-extras = {
    url = "github:nagy/emacs-map-extras";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.emacs-ctags-mode = {
    url = "github:nagy/emacs-ctags-mode";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.nixos-el = {
    url = "github:nagy/nixos.el";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  inputs.tired = {
    url = "github:nagy/tired";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      treefmt-nix,
      nur,
      dot,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = pkgs.lib;

      # Modules take these instead of calling builtins.getFlake.  Every
      # input that this file does not use directly goes to the modules.
      flakes = builtins.removeAttrs inputs [
        "self"
        "nixpkgs"
        "flake-parts"
        "treefmt-nix"
        "nur"
      ];

      # This repository registered as a repo inside the full NUR closure.
      nurPkgs = import nur.outPath {
        inherit pkgs;
        nurpkgs = pkgs;
        repoOverrides = {
          nagy = import ./. { inherit pkgs flakes; };
        };
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ treefmt-nix.flakeModule ];
      systems = [ system ];

      # `lib` is not a per-system output, so it lives outside perSystem.
      flake.lib = import ./lib/nixos.nix { inherit pkgs; };

      perSystem =
        { ... }:
        {
          # Reuse the single nixpkgs instance above instead of importing
          # another one for perSystem.
          _module.args.pkgs = pkgs;

          # NUR convention: the full attribute set that default.nix returns.
          # It carries lib, modules, python3Packages, emacsPackages,
          # my-build-env and the package sets that are not plain derivations.
          legacyPackages = import ./. {
            inherit
              pkgs
              flakes
              dot
              ;
            nur = nurPkgs;
          };

          # The flake schema wants derivations only. Discover the packages
          # with the same trick that default.nix uses, so no package name is
          # listed.
          packages = lib.packagesFromDirectoryRecursive {
            directory = ./pkgs/by-name;
            callPackage = pkgs.callPackage;
          };

          # treefmt-nix adds `formatter` and `checks.treefmt` from this.
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            settings.excludes = [
              # Pre-existing unformatted files.  Format one, then drop its entry.
              "modules/nix.nix"
              "modules/shortcommands_common.nix"
              "modules/xcompose.nix"
            ];
          };
        };
    };
}
