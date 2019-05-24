{ ... }:
{
  # Check that there is no clash with nixos/modules/misc/ids.nix
  config = {
    ids.uids = {
      peertube = 394;
      redis = 395;
      nullmailer = 396;
      mediagoblin = 397;
      diaspora = 398;
      mastodon = 399;
    };
    ids.gids = {
      peertube = 394;
      redis = 395;
      nullmailer = 396;
      mediagoblin = 397;
      diaspora = 398;
      mastodon = 399;
    };
  };
}
