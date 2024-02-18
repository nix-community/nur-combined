{
  description = "oluceps' flake";
  outputs = inputs@{ flake-parts, ... }:
    let extraLibs = (import ./hosts/lib.nix inputs); /* f = excludes: valueFunc: */
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = import ./hosts inputs;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { pkgs, system, inputs', ... }: {

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = with inputs;[
            agenix-rekey.overlays.default
            fenix.overlays.default
            self.overlays.default
          ];
        };

        checks = with pkgs; {
          pre-commit-check =
            inputs.pre-commit-hooks.lib.${system}.run {
              src = lib.cleanSource ./.;
              hooks = { nixpkgs-fmt.enable = true; };
            };
        };

        devShells.default = with pkgs; mkShell {
          packages = [ agenix-rekey home-manager just ];
        };

        packages =
          let
            shadowedPkgs = [
              "glowsans" # multi pkgs
              "opulr-a-run" # ?
              "tcp-brutal" # kernelModule
              "shufflecake"
            ];
          in
          extraLibs.genFilteredDirAttrsV2 ./pkgs shadowedPkgs (n: pkgs.${n});
      };

      flake = {

        agenix-rekey = inputs.agenix-rekey.configure {
          userFlake = inputs.self;
          nodes = with inputs.nixpkgs.lib;
            filterAttrs (n: _: !elem n [ "nixos" "bootstrap" ]) inputs.self.nixosConfigurations;
        };

        overlays =
          {
            default = final: prev:
              let
                shadowedPkgs = [
                  "tcp-brutal"
                  "shufflecake"
                ];
              in
              extraLibs.genFilteredDirAttrsV2 ./pkgs shadowedPkgs
                (name: final.callPackage (./pkgs + "/${name}.nix") { });

            lib = final: prev: extraLibs;
          };

        nixosModules =
          let
            shadowedModules = [ ];
            modules =
              extraLibs.genFilteredDirAttrsV2 ./modules shadowedModules
                (n: import (./modules + "/${n}.nix"));

            default = { ... }: {
              imports = builtins.attrValues modules;
            };
          in
          modules // { inherit default; };
      };

    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-22.url = "github:NixOS/nixpkgs?rev=c91d0713ac476dfb367bbe12a7a048f6162f039c";
    nixpkgs-dae.url = "github:NixOS/nixpkgs?rev=c43c81954dee4f0b383a6c4ee3f3c66384146d42";
    nixpkgs-rebuild.url = "github:SuperSandro2000/nixpkgs?rev=449114c6240520433a650079c0b5440d9ecf6156";
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.niri-src.url = "github:YaLTeR/niri";
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    RyanGibb = {
      url = "github:RyanGibb/nixos";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    atuin = {
      url = "github:atuinsh/atuin";
    };
    swayfx = {
      url = "github:WillPower3309/swayfx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    conduit = {
      url = "gitlab:famedly/conduit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nyx = {
      # url = "/home/elen/Src/nyx";
      url = "github:oluceps/nyx";
    };
    factorio-manager = {
      url = "github:asoul-rec/factorio-manager";
      # url = "github:oluceps/nyx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    j-link.url = "github:liff/j-link-flake";
    devenv.url = "github:cachix/devenv";
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
    };
    # path:/home/riro/Src/flake.nix
    dae.url = "github:daeuniverse/flake.nix?rev=e16931c97e18eddd6a36b182687701cd6d03b284";
    # nixyDomains.url = "/home/elen/nixyDomains";
    nixyDomains.url = "github:oluceps/nixyDomains";
    nuenv.url = "github:DeterminateSystems/nuenv";
    EHfive.url = "github:EHfive/flakes";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    resign.url = "github:oluceps/resign";
    nil.url = "github:oxalica/nil";
    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    misskey = {
      url = "github:Ninlives/misskey.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixified-ai.url = "github:nixified-ai/flake";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    typst-lsp.url = "github:nvarner/typst-lsp";
    nur-pkgs = {
      url = "github:oluceps/nur-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpicker.url = "github:hyprwm/hyprpicker";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
    impermanence.url = "github:nix-community/impermanence";
    clash-meta.url = "github:MetaCubeX/Clash.Meta/Alpha";
    alejandra.url = "github:kamadorueda/alejandra";
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    helix.url = "github:helix-editor/helix";
    hyprland.url = "github:vaxerski/Hyprland";
    berberman.url = "github:berberman/flakes";
    # clansty.url = "github:clansty/flake";
  };

}
