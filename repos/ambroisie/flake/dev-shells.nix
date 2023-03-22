{ inputs, ... }:
{
  perSystem = { self', config, pkgs, ... }: {
    devShells = {
      default = pkgs.mkShell {
        name = "NixOS-config";

        nativeBuildInputs = with pkgs; [
          gitAndTools.pre-commit
          nixpkgs-fmt
        ];

        shellHook = ''
          ${config.pre-commit.installationScript}
        '';
      };
    };
  };
}
