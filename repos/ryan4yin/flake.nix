{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  # NUR's nixpkgs packages Nushell 0.112.2. dsh-nu is tested with 0.115.1, so
  # take Nushell from the nixpkgs revision that packages that version.
  inputs.nixpkgs-nu.url = "github:NixOS/nixpkgs/55ba7f49ef2962b42cbd126522b7df5f95037679";
  outputs = {
    self,
    nixpkgs,
    nixpkgs-nu,
  }: let
    systems = [
      "x86_64-linux"
      # "i686-linux"
      "aarch64-linux"
      # "armv6l-linux"
      # "armv7l-linux"
      "riscv64-linux"

      # "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
        nushell = nixpkgs-nu.legacyPackages.${system}.nushell;
      });
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
  };
}
