{
  description = "NicoWeio's NUR packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          radiopropa = pkgs.callPackage ./radiopropa {
            python = pkgs.python312;
            numpy = pkgs.python312Packages.numpy;
          };
          rainlendar2 = pkgs.callPackage ./rainlendar2 { };
        });
    };
}
