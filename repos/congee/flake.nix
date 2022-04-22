{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });

      apps = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          localpkgs = import ./mkver.nix { inherit (pkgs) lib pkgs; };
        in
        {
          default = pkgs.writeScriptBin "foo" ''
            echo '${builtins.toJSON localpkgs}'
          '';
        });
    };
}
