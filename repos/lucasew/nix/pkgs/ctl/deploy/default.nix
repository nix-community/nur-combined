{ lib, pkgs, ... }:
{
  subcommands.deploy = {
    description = "Deploy components in specific nodes";
    flags = [
      { description = "Repo root"; keywords = ["-r"]; variable = "NIXCFG_ROOT_PATH"; validator = "dir"; }
    ];
    action.bash = "echo Deploy what?";
    subcommands.riverwood.subcommands = let
      hostname = "riverwood";
      ip = "192.168.69.2";
    in {
      build = {
        allowExtraArguments = true;
        action.bash = ''
          cd $NIXCFG_ROOT_PATH
          nix build -L .#nixosConfigurations.${hostname}.config.system.build.toplevel "$@"
        '';
      };
      switch = {
        allowExtraArguments = true;
        action.bash = ''
          cd $NIXCFG_ROOT_PATH
          nix build -L .#nixosConfigurations.${hostname}.config.system.build.toplevel "$@"
          nix-copy-closure --to ${ip} result || true
          ssh -t lucasew@${ip} sudo $(readlink result)/bin/switch-to-configuration switch "$@"
        '';
      };
      boot = {
        allowExtraArguments = true;
        action.bash = ''
          cd $NIXCFG_ROOT_PATH
          nix build -L .#nixosConfigurations.${hostname}.config.system.build.toplevel "$@"
          nix-copy-closure --to ${ip} result || true
          ssh -t lucasew@${ip} sudo $(readlink result)/bin/switch-to-configuration boot "$@"
        '';
      };
    };
    subcommands.whiterun.subcommands = let
      hostname = "whiterun";
      ip = "192.168.69.1";
    in {
      build = {
        allowExtraArguments = true;
        action.bash = ''
          cd $NIXCFG_ROOT_PATH
          nix build -L .#nixosConfigurations.${hostname}.config.system.build.toplevel "$@"
        '';
      };
      switch = {
        allowExtraArguments = true;
        action.bash = ''
          cd $NIXCFG_ROOT_PATH
          nix build -L .#nixosConfigurations.${hostname}.config.system.build.toplevel "$@"
          nix-copy-closure --to ${ip} result
          ssh -t lucasew@${ip} sudo $(readlink result)/bin/switch-to-configuration switch "$@"
        '';
      };
      boot = {
        allowExtraArguments = true;
        action.bash = ''
          cd $NIXCFG_ROOT_PATH
          nix build -L .#nixosConfigurations.${hostname}.config.system.build.toplevel "$@"
          nix-copy-closure --to ${ip} result
          ssh -t lucasew@${ip} sudo $(readlink result)/bin/switch-to-configuration boot "$@"
        '';
      };
    };
    subcommands.home.subcommands = {
      build = {
        allowExtraArguments = true;
        action.bash = ''
          cd $NIXCFG_ROOT_PATH
          nix build -L .#homeConfigurations.main.activationPackage
        '';
      };
      switch = {
        allowExtraArguments = true;
        action.bash = ''
          cd $NIXCFG_ROOT_PATH
          nix build -L .#homeConfigurations.main.activationPackage
          $(readlink result)/activate "$@"
        '';
      };

    };
  };
}
