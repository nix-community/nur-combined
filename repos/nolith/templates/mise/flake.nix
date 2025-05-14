{
  description = "mise template";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      imports = [
        ({inputs, ...}: {
          perSystem = {system, ...}: {
            _module.args = {
              pkgs = import inputs.nixpkgs {
                inherit system;
              };
            };
          };
        })
      ];

      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;

        # Development shell with necessary tools
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            mise
          ];

          shellHook = ''
            eval "$(mise activate)"
          '';
        };
      };
    };
}
