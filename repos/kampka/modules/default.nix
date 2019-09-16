{
  direnv = ./programs/direnv;
  firefox = ./programs/firefox;
  zsh-history = ./programs/zsh-history;

  dns-cache = ./services/dns-cache;
  msmtp-mailqueue = ./services/msmtp-mailqueue;
  nginx = ./services/nginx;
  nixops-auto-upgrade = ./services/nixops-auto-upgrade;
  ntp = ./services/ntp;
  systemd-failure-email = ./services/systemd-failure-email;
  tmux = ./services/tmux;

  headless = ./profiles/headless.nix;
}
