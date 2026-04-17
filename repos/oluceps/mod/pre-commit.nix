{ inputs, ... }:
{
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      pre-commit = {
        check.enable = true;
        settings.hooks = {
          nixfmt.enable = true;
          detect-private-keys.enable = true;

          dangerous-marker =
            let
              checkScript = pkgs.writeShellScript "check-dangerous.sh" ''
                if ${pkgs.ripgrep}/bin/rg --line-number --color=always --fixed-strings "# DANGEROUS:" "$@"; then
                  echo -e "\n\033[0;31m[!] commit forbidden!\033[0m"
                  exit 1
                fi
              '';
            in
            {
              enable = true;
              name = "Check for dangerous markers";

              entry = "${checkScript}";
              excludes = [ "pre-commit\\.nix" ];

              language = "system";
              pass_filenames = true;
              types = [ "text" ];
            };
        };
      };

    };
}
