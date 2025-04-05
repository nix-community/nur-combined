{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  commafeed = ./commafeed.nix;
  pgbackupsync = ./pgbackupsync.nix;
  gitea = ./gitea.nix;
  gitea-dump-sync = ./gitea-dump-sync.nix;
}
