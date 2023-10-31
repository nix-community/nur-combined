# Core system configuration
{ ... }:
{
  my.system = {
    nix = {
      cache = {
        # This server is the one serving the cache, don't try to query it
        selfHosted = false;
      };
    };
  };
}
