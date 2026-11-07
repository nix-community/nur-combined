{
  description = "NUR packages of @nagy";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    # One nixpkgs closure, no duplicates.
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Full NUR closure.  Flake callers get it without a NIX_PATH lookup.
  inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.jsonrpc-httpproxy = {
    url = "github:nagy/jsonrpc-httpproxy";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Inputs that modules used to fetch with builtins.getFlake.  Pinning them
  # here keeps evaluation offline and lets the modules get one nixpkgs.
  inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.bruvtab = {
    url = "github:pschmitt/bruvtab";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-bruvtab = {
    url = "github:nagy/emacs-bruvtab";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-buffer-url = {
    url = "github:nagy/emacs-buffer-url";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-git-bug = {
    url = "github:nagy/emacs-git-bug";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-openstack-modes = {
    url = "github:nagy/emacs-openstack-modes";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-gitlab-modes = {
    url = "github:nagy/emacs-gitlab-modes";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-network-modes = {
    url = "github:nagy/emacs-network-modes";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.org-jxl-images = {
    url = "github:nagy/org-jxl-images.el";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.yublin = {
    url = "github:nagy/yublin.el";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.go-mod-ts-extras-mode = {
    url = "github:nagy/go-mod-ts-extras-mode";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.gguf = {
    url = "github:nagy/gguf.el";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.crate = {
    url = "github:nagy/crate.el";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.derivation = {
    url = "github:nagy/derivation.el";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.toml-ts-cargo-mode = {
    url = "github:nagy/toml-ts-cargo-mode";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-ron-ts-mode = {
    url = "github:nagy/emacs-ron-ts-mode";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-openrpc-mode = {
    url = "github:nagy/emacs-openrpc-mode";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-ipfs-modes = {
    url = "github:nagy/emacs-ipfs-modes";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.emacs-ctags-mode = {
    url = "github:nagy/emacs-ctags-mode";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixos-el = {
    url = "github:nagy/nixos.el";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      treefmt-nix,
      nur,
      jsonrpc-httpproxy,
      ...
    }:
    let
      system = "x86_64-linux";
      # allowBroken: some packages here track rolling nixpkgs and depend on
      # upstream packages that nixpkgs currently marks broken.
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowBroken = true;
          allowUnfree = true;
        };
      };
      lib = pkgs.lib;

      # Modules take these instead of calling builtins.getFlake.  Every
      # input that this file does not use directly goes to the modules.
      flakes = builtins.removeAttrs inputs [
        "self"
        "nixpkgs"
        "treefmt-nix"
        "nur"
        "jsonrpc-httpproxy"
      ];

      # This repository registered as a repo inside the full NUR closure.
      nurPkgs = import nur.outPath {
        inherit pkgs;
        nurpkgs = pkgs;
        repoOverrides = {
          nagy = import ./. { inherit pkgs flakes; };
        };
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        settings.excludes = [
          # Pre-existing unformatted files.  Format one, then drop its entry.
          "lib/emacs.nix"
          "modules/htop.nix"
          "modules/nix.nix"
          "modules/shortcommands_common.nix"
          "modules/xcompose.nix"
          "pkgs/by-name/ksv/gemset.nix"
        ];
      };
    in
    {
      # NUR convention: the full attribute set that default.nix returns.
      # It carries lib, modules, python3Packages, emacsPackages, my-build-env
      # and the package sets that are not plain derivations.
      legacyPackages.${system} = import ./. {
        inherit pkgs jsonrpc-httpproxy flakes;
        nur = nurPkgs;
      };

      # The flake schema wants derivations only. Discover the packages with
      # the same trick that default.nix uses, so no package name is listed.
      packages.${system} = lib.packagesFromDirectoryRecursive {
        directory = ./pkgs/by-name;
        callPackage = pkgs.callPackage;
      };

      # Library API for private flakes, for example a dotfiles repository.
      lib = import ./lib/nixos.nix { inherit pkgs; };

      checks.${system}.formatting = treefmtEval.config.build.check self;

      formatter.${system} = treefmtEval.config.build.wrapper;
    };
}
