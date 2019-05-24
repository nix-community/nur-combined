{
  myids = ./myids.nix;
  secrets = ./secrets.nix;

  webstats = ./webapps/webstats;
  diaspora = ./webapps/diaspora.nix;
  etherpad-lite = ./webapps/etherpad-lite.nix;
  mastodon = ./webapps/mastodon.nix;
  mediagoblin = ./webapps/mediagoblin.nix;
  peertube = ./webapps/peertube.nix;

  websites = ./websites;
} // (if builtins.pathExists ./private then import ./private else {})
