{ lib, mkFormatterModule, ... }:
{
  meta.maintainers = with lib.maintainers; [ wwmoraes ];

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
