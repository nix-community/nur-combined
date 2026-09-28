{ lib, mkFormatterModule, ... }:
{
  meta.maintainers = with lib.maintainers; [ wwmoraes ];

  imports = [
    (mkFormatterModule {
      name = "shellcheck-posix";
      package = "shellcheck";
      includes = [
        "*.sh"
      ];
    })
    (import ./shellcheck.nix {
      name = "shellcheck-posix";
      shell = "sh";
    })
  ];
}
