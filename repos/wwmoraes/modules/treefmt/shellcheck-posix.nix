{ lib, mkFormatterModule, ... }:
{
  meta.maintainers = with lib.maintainers; [ wwmoraes ];

  imports = [
    (mkFormatterModule {
      name = "shellcheck-posix";
      package = "shellcheck";
      args = [ "--shell=sh" ];
      includes = [
        "*.sh"
      ];
    })
  ];
}
