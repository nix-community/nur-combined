{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "i686-linux"
      # disabled due to waybar
      #"x86_64-darwin"
      "aarch64-linux"
      # disabled due to waybar
      #"armv6l-linux"
      "armv7l-linux"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    packages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      });
    overlays.default = import ./overlay.nix;
    hydraJobs = let
      hydraSystems = ["x86_64-linux" "aarch64-linux"];
      inherit (nixpkgs) lib;
    in
      lib.foldl' lib.recursiveUpdate {} (lib.flatten (builtins.map (system: let
        packages = self.packages.${system};
        names = builtins.attrNames packages;
      in
        builtins.map (name: {
          "${name}".${system} = packages.${name};
        })
        names)
      hydraSystems));
  };
}
