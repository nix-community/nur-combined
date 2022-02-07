{ config, lib, options, ... }:

{
  config.age = {
    identityPaths = options.age.identityPaths.default ++ [
      "/home/alarsyo/.ssh/id_ed25519"
    ];
  };
}
