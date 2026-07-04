{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    nur.url = "github:nix-community/NUR";
    
    nur-ximimoments.url = "github:ximimoments/nur-packages";
  };

  outputs = { self, nixpkgs, nur, nur-ximimoments, ... }: {
    nixosConfigurations.tu-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            nur.overlay
            (final: prev: {
              nur.repos.ximimoments = nur-ximimoments.legacyPackages.${pkgs.system};
            })
          ];
          
          environment.systemPackages = [ pkgs.nur.repos.ximimoments.katifetch ];
        })
      ];
    };
  };
}
