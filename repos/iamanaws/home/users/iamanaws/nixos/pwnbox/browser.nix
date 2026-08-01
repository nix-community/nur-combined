{
  pkgs,
  ...
}:

{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    commandLineArgs = [
      "--password-store=gnome-libsecret"
    ];
    extensions = [
      "gcknhkkoolaabfmlnjonogaaifnjlfnp" # foxyproxy
      "gppongmhjkpfnbhagpmjfkannfbllamg" # wappalyzer
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # privacy badger
      "lnjaiaapbakfhlbjenjkhffcdpoompki" # catppuccin github icons
      "gbmdgpbipfallnflgajpaliibnhdgobh" # json viewer
    ];
  };
}
