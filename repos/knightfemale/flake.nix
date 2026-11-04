{
  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts/main";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";

    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs =
    inputs@{
      flake-parts,
      import-tree,
      ...
    }:
    flake-parts.lib.mkFlake
      {
        inherit
          inputs
          ;
      }
      {
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];

        imports = [
          (import-tree ./outputs)
        ];
      };
}
