{
  lib,
  ...
}:
{
  options = {
    flake.lib = lib.mkOption {
      type = with lib.types; lazyAttrsOf raw;
      default = { };
      description = ''
        Global lib functions
      '';
    };
  };
}
