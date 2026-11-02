{ ... }:
{
  perSystem = { config, pkgs, ... }: {
    devShells = {
      default = pkgs.mkShellNoCC {
        name = "NixOS-config";

        packages = with pkgs; [
          nixpkgs-fmt
        ] ++ config.pre-commit.settings.enabledPackages;

        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
      };
    };
  };
}
