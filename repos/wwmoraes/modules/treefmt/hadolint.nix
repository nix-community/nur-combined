{ lib, mkFormatterModule, ... }:
{
  meta.maintainers = [
    lib.maintainers.wwmoraes
  ];

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
