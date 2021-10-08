{
  commit-notifier = import ./services/commit-notifier.nix;
  vlmcsd = import ./services/vlmcsd.nix;
  trojan = import ./services/trojan.nix;
  tprofile = import ./programs/tprofile/tprofile.nix;
  telegram-send = import ./programs/telegram-send.nix;
}
