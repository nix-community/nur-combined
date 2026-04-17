{ lib, ... }:
{
  flake.modules.nixos.identity = {
    options.identity.user = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "The primary user of this system";
    };
  };
}
