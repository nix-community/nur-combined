{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Añade tu repositorio NUR aquí
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nur, ... }: {
    nixosConfigurations.tu-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          # Esto registra el NUR en tu sistema
          nixpkgs.overlays = [ nur.overlay ];
          
          # Ahora esto ya funcionará porque cargamos el overlay
          environment.systemPackages = [ pkgs.nur.repos.ximimoments.katifetch ];
        })
      ];
    };
  };
}
