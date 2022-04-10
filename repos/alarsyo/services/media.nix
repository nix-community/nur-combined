{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    ;

  mediaServices = builtins.attrValues {
    inherit
      (config.my.services)
      jellyfin
      transmission
      ;
  };
  needed = builtins.any (service: service.enable) mediaServices;
in {
  config.users.groups.media = mkIf needed {};
}
