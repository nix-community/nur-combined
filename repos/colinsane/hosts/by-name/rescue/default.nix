{ ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.persist.enable = false;  # what we mean here is that the image is immutable; `/` is still tmpfs.
  sane.nixcache.enable = false;  # don't want to be calling out to dead machines that we're *trying* to rescue

  # auto-login at shell
  services.getty.autologinUser = "colin";
  # users.users.colin.initialPassword = "colin";
}
