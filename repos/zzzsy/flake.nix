{
  description = "zzzsy's NixOS Flake 3.0";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager";

    preservation.url = "github:WilliButz/preservation";
    flake-parts.url = "github:hercules-ci/flake-parts";

    fast-nix-gc.url = "github:Mic92/fast-nix-gc";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    infuse.url = "git+https://github.com/zzzsyyy/infuse.nix.git";
    infuse.flake = false;
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
    vaultix.url = "github:milieuim/vaultix";
    direnv-instant.url = "github:Mic92/direnv-instant";

    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    llm-agents.url = "github:numtide/llm-agents.nix";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
    flake-compat.flake = false;
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    let
      lib = inputs.nixpkgs.lib.extend (
        final: prev: {
          my = import ./lib {
            inherit inputs;
            lib = final;
          };
        }
      );
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs.lib = lib;
      }
      {
        debug = true;
        imports = [
          inputs.pre-commit-hooks.flakeModule
          inputs.vaultix.flakeModules.default
        ]
        ++ import ./parts;
        systems = [ "x86_64-linux" ];
      };
}
