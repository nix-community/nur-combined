{
  config,
  pkgs,
  lib,
  ...
}: {
  # set postgresql version so we don't get any bad surprise
  config.services.postgresql = {
    package = pkgs.postgresql_16;
  };
}
