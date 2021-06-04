{ lib, ... }:
with lib;
{
  options.my.secrets = mkOption {
    type = types.attrs;
  };

  config.my.secrets = {
    # I'm not sure hiding this is very important, but it *seems* like a bad idea
    # to expose this
    bluetooth-mouse-mac-address = fileContents ./bluetooth-mouse-mac-address.secret;
  };
}
