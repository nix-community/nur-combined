{ lib, mkFormatterModule, ... }:
{
  meta.maintainers = [
    lib.maintainers.wwmoraes
  ];

  imports = [
    (mkFormatterModule {
      name = "editorconfig";
      package = "editorconfig-checker";
      args = [ ];
      excludes = [
        "*.lock"
      ];
    })
  ];
}
