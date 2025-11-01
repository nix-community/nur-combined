{ lib, mkFormatterModule, ... }:
{
  meta.maintainers = [
    lib.maintainers.wwmoraes
  ];

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
