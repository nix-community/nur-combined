{
  description = "Packages from my personal dotfiles";

  inputs = {
    puntbestanden = {
      url = "github:dtomvan/puntbestanden";
      inputs.bart.follows = "";
      inputs.catppuccin.follows = "";
      inputs.copyparty.follows = "";
      inputs.deploy-rs.follows = "";
      inputs.devshell.follows = "";
      inputs.direnv-instant.follows = "";
      inputs.disko.follows = "";
      inputs.flake-parts.follows = "";
      inputs.home-manager.follows = "";
      inputs.lazy-apps.follows = "";
      inputs.ncro.follows = "";
      inputs.nix-cache-beacon.follows = "";
      inputs.nix-index-database.follows = "";
      inputs.nixos-small.follows = "";
      inputs.nixvim.follows = "";
      inputs.nixocaine.follows = "";
      inputs.nix-maid.follows = "";
      inputs.noctalia.follows = "";
      inputs.noctalia-greeter.follows = "";
      inputs.nur.follows = "";
      inputs.sops.follows = "";
      inputs.srvos.follows = "";
      inputs.tasks.follows = "";
      inputs.treefmt-nix.follows = "";
    };
    nixpkgs.follows = "puntbestanden/nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/devshell.nix
        ./modules/eval-check.nix
        ./modules/formatter.nix
        ./modules/koil-test.nix
        ./modules/nixos.nix
        ./modules/packages.nix
        ./modules/systems.nix
      ];
    };
}
