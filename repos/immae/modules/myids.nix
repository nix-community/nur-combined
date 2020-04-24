{ ... }:
{
  # Check that there is no clash with nixos/modules/misc/ids.nix
  config = {
    ids.uids = {
      backup = 389;
      vhost = 390;
      openarc = 391;
      opendmarc = 392;
      peertube = 394;
      redis = 395;
      nullmailer = 396;
      mediagoblin = 397;
      diaspora = 398;
      mastodon = 399;
    };
    ids.gids = {
      nagios = 11; # commented in the ids file
      backup = 389;
      vhost = 390;
      openarc = 391;
      opendmarc = 392;
      peertube = 394;
      redis = 395;
      nullmailer = 396;
      mediagoblin = 397;
      diaspora = 398;
      mastodon = 399;
    };
  };
}
