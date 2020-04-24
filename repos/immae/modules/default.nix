{
  myids = ./myids.nix;
  secrets = ./secrets.nix;
  filesWatcher = ./filesWatcher.nix;

  webstats = ./webapps/webstats;
  diaspora = ./webapps/diaspora.nix;
  etherpad-lite = ./webapps/etherpad-lite.nix;
  mastodon = ./webapps/mastodon.nix;
  mediagoblin = ./webapps/mediagoblin.nix;
  peertube = ./webapps/peertube.nix;
  fiche = ./webapps/fiche.nix;

  opendmarc = ./opendmarc.nix;
  openarc = ./openarc.nix;

  duplyBackup = ./duply_backup;
  rsyncBackup = ./rsync_backup;
  naemon = ./naemon;

  php-application = ./websites/php-application.nix;
  websites = ./websites;
} // (if builtins.pathExists ./private then import ./private else {})
