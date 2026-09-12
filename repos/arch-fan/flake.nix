{
  description = "arch-fan NUR packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      packages = import ./. {
        inherit pkgs;
      };
    in
    {
      packages.${system} = packages;

      apps.${system}.update =
        let
          update = pkgs.writeShellApplication {
            name = "update";
            runtimeInputs = [ pkgs.nix-update ];
            text = builtins.readFile ./scripts/update.sh;
          };
        in
        {
          type = "app";
          program = pkgs.lib.getExe update;
        };
    };
}
