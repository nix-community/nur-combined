{
  direnv = ./programs/direnv;
  firefox = ./programs/firefox;
  nix-search = ./programs/nix-search;
  zsh-history = ./programs/zsh-history;

  dns-cache = ./services/dns-cache;
  matrix = ./services/matrix;
  msmtp-mailqueue = ./services/msmtp-mailqueue;
  nginx = ./services/nginx;
  nixops-auto-upgrade = ./services/nixops-auto-upgrade;
  ntp = ./services/ntp;
  systemd-failure-email = ./services/systemd-failure-email;
  tmux = ./services/tmux;

  desktop = ./profiles/desktop.nix;
  headless = ./profiles/headless.nix;
}
