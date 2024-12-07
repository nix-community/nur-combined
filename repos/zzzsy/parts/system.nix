{ self, inputs, ... }:
let
  username = "zzzsy";

  inherit (inputs)
    home-manager
    nixpkgs
    preservation
    sops-nix
    chaotic
    # nixos-cosmic
    nvfetcher
    daeuniverse
    #ghostty
    lanzaboote
    neovim-nightly-overlay
    nur
    #stylix
    zig
    ;

  inherit (nixpkgs.lib) attrValues;
  mkHost =
    {
      hostName,
      system,
      modules,
      overlays ? [ nvfetcher.overlays.default ],
    }:
    {
      ${hostName} = nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          [
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = attrValues self.hmModules;
              };
              nixpkgs = {
                overlays = [
                  (final: prev: {
                    #ghostty = ghostty.packages.x86_64-linux.default;
                    dae = daeuniverse.packages.${system}.dae-unstable;
                    my = self.packages."${system}";
                    chaotic = chaotic.packages.${system};
                  })
                ] ++ overlays;
              };
              networking.hostName = hostName;
            }

            home-manager.nixosModules.home-manager
            ../hosts/common
            ../hosts/${hostName}
            (import ../home username)
          ]
          ++ (attrValues self.nixosModules)
          ++ modules;
        specialArgs = {
          inherit inputs;
        };
      };
    };
in
{
  flake.nixosConfigurations = (
    mkHost {
      system = "x86_64-linux";
      hostName = "laptop";
      modules = [
        preservation.nixosModules.default
        sops-nix.nixosModules.sops
        chaotic.nixosModules.default
        # nixos-cosmic.nixosModules.default
        daeuniverse.nixosModules.dae
        # daeuniverse.nixosModules.daed
        lanzaboote.nixosModules.lanzaboote
        nur.modules.nixos.default
        # stylix.nixosModules.stylix
        # nixos-hardware.nixosModules.common-cpu-amd-pstate
        # nixos-hardware.nixosModules.common-gpu-amd
        # nixos-hardware.nixosModules.common-pc-ssd
      ];
      overlays = [
        self.overlays.mutter
        nur.overlays.default
        zig.overlays.default
        neovim-nightly-overlay.overlays.default
      ];
    }
  );
}
