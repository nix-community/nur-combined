{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    packages.x86_64-linux.ubuntu2404 = with nixpkgs.legacyPackages.x86_64-linux.pkgs.vmTools; makeImageTestScript diskImages.ubuntu2404x86_64;

    packages.x86_64-linux.default = self.packages.x86_64-linux.ubuntu2404;
  };
}
