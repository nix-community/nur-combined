{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nixConfig = {
    extra-substituters = [ "https://nixcache.mathieurene.com/nur" ];
    extra-trusted-public-keys = [ "nur:/HeC3enYzhY920VJrGNSUdMOqXUh3Y/zLo3+f5IZjfM=" ];
  };
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      lib = nixpkgs.lib;
    in
    {
      packages = forAllSystems (system: 
        let
          pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; }; };
        in
          pkgs.callPackage ./pkgs {}
      );
    };
}
