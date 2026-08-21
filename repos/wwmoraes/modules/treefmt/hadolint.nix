{ lib, mkFormatterModule, ... }:
{
  meta.maintainers = with lib.maintainers; [ wwmoraes ];

  imports = [
    (mkFormatterModule {
      name = "hadolint";
      package = "hadolint";
      args = [ ];
      ## TODO generate config file
      includes = [
        "Dockerfile"
        "*.Dockerfile"
        "Dockerfile.*"
      ];
    })
  ];
}
