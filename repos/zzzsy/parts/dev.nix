{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          ${config.pre-commit.installationScript}
        '';
        packages = with pkgs; [
          just
          nix-output-monitor
          dix
          nixfmt-rs
          nixd
          nix-update
        ];
      };
      pre-commit.settings.hooks = {
        nil.enable = true;
        actionlint.enable = true;
        nixfmt-rfc-style.enable = true;
        nixfmt-rfc-style.package = pkgs.nixfmt-rs;
      };

      devShells.secret =
        with pkgs;
        mkShell {
          nativeBuildInputs = [
            sops
            age
            ssh-to-age
            ssh-to-pgp
          ];
          shellHook = ''
            export PS1="\e[0;31m(Secret)\w\$ \e[m"
          '';
        };
    };
}
