{
  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs-pine64.url = "nixpkgs/dfd82985c273aac6eced03625f454b334daae2e8";
    mobile-nixos = {
      # url = "github:nixos/mobile-nixos";
      url = "github:nixos/mobile-nixos/efbe2c3c5409c868309ae0770852638e623690b5";
      flake = false;
    };
    home-manager-pine64.url = "github:nix-community/home-manager/release-22.05";
  };

  outputs = { self, nixpkgs-pine64, mobile-nixos, home-manager-pine64 }: rec {
    nixosConfigurations.pinephone = (nixpkgs-pine64.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { home-manager = home-manager-pine64; };
      modules = [
        (import "${mobile-nixos}/lib/configuration.nix" {
          device = "pine64-pinephone";
        })
        ./hosts/pesto/default.nix
      ];
    });
    pinephone-img = nixosConfigurations.pinephone.config.mobile.outputs.u-boot.disk-image;
  };
}
