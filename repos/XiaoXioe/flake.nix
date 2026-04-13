{
  description = "Koleksi custom Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true;};
      lib = nixpkgs.lib;

      pkgsPath = ./pkgs;

      # Baca isi direktori ./pkgs, lalu saring agar hanya mengambil tipe "directory"
      packageDirs = lib.filterAttrs (name: type: type == "directory") (builtins.readDir pkgsPath);

      # Ambil nama-nama direktorinya saja menjadi sebuah list (misal: [ "disbox" "freqtrade" ... ])
      packageNames = builtins.attrNames packageDirs;
    in
    {
      packages.${system} = lib.genAttrs packageNames (
        name: pkgs.callPackage (pkgsPath + "/${name}/default.nix") { }
      );
    };
}
