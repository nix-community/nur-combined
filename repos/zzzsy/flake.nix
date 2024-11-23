{
  description = "zzzsy's NixOS Flake 3.0";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    preservation.url = "github:WilliButz/preservation";
    flake-parts.url = "github:hercules-ci/flake-parts";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    daeuniverse.url = "github:daeuniverse/flake.nix";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nix-matlab = {
      inputs.nixpkgs.follows = "nixpkgs-2405";
      url = "github:ykttt/nix-matlab";
    };

    nur.url = "github:nix-community/NUR";
    #stylix.url = "github:danth/stylix";
    zig.url = "github:mitchellh/zig-overlay";
    #ghostty.url = "git+ssh://git@github.com/ghostty-org/ghostty";
    #ghostty.inputs.nixpkgs-stable.follows = "nixpkgs";
    #ghostty.inputs.nixpkgs-unstable.follows = "nixpkgs";
    #nixos-cosmic = {
    #  url = "github:lilyinstarlight/nixos-cosmic";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.pre-commit-hooks.flakeModule ] ++ import ./parts;
      systems = [ "x86_64-linux" ];
    };
}
