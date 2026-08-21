{ lib, mkFormatterModule, ... }:
{
  meta.maintainers = with lib.maintainers; [ wwmoraes ];

  imports = [
    (mkFormatterModule {
      name = "shellcheck-bash";
      package = "shellcheck";
      args = [ "--shell=bash" ];
      includes = [
        "*.bash"
        # direnv
        "*.envrc"
        "*.envrc.*"
      ];
    })
  ];
}
