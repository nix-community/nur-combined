{
  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs.url = "nixpkgs/dfd82985c273aac6eced03625f454b334daae2e8";
    mobile-nixos = {
      # url = "github:nixos/mobile-nixos";
      url = "github:nixos/mobile-nixos/efbe2c3c5409c868309ae0770852638e623690b5";
      flake = false;
    };
    home-manager.url = "github:nix-community/home-manager/release-22.05";
  };

  outputs = { self, nixpkgs, mobile-nixos, home-manager }: rec {
    nixosConfigurations.pinephone = (nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit home-manager; };
      modules = [
        (import "${mobile-nixos}/lib/configuration.nix" {
          device = "pine64-pinephone";
        })
        ./modules/default.nix
      ];
    });
    pinephone-img = nixosConfigurations.pinephone.config.mobile.outputs.u-boot.disk-image;
  };
}
