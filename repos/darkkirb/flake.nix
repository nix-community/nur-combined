{
  description = "Lotte’s nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (self: super: {
              openssl = super.openssl_1_1; # TODO: workaround for openssl critical vuln
            })
          ];
        };
        inherit (pkgs) lib;
        nur = import ./default.nix {inherit pkgs;};
        packages = lib.filterAttrs (n: _: n != "overlays" && n != "modules" && n != "lib") nur;
      in rec {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            statix
            nix-prefetch
          ];
        };

        inherit packages;
        inherit (nur) overlays modules lib;

        hydraJobs =
          if (system == "x86_64-linux") || (system == "aarch64-linux")
          then {
            inherit packages devShells formatter;
          }
          else {};
      }
    );
}
