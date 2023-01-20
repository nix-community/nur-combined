{
  commit-notifier = import ./services/commit-notifier.nix;
  dot-tar = import ./services/dot-tar.nix;
  vlmcsd = import ./services/vlmcsd.nix;
  trojan = import ./services/trojan.nix;
  tprofile = import ./programs/tprofile/tprofile.nix;
  telegram-send = import ./programs/telegram-send.nix;
  tg-send = import ./programs/tg-send.nix;
}
