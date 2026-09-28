{ lib, mkFormatterModule, ... }:
{
  meta.maintainers = with lib.maintainers; [ wwmoraes ];

  imports = [
    (mkFormatterModule {
      name = "shellcheck-bash";
      package = "shellcheck";
      includes = [
        "*.bash"
        # direnv
        "*.envrc"
        "*.envrc.*"
      ];
    })
    (import ./shellcheck.nix {
      name = "shellcheck-bash";
      shell = "bash";
    })
  ];
}
