{
  base = [ "https://mirror.tuna.tsinghua.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];
  caches = {
    niri = {
      url = "https://niri-computer-use.cachix.org";
      key = "niri-computer-use.cachix.org-1:K5LGfljid+PkRn02OLbwsmngqBCoLkbDi9hRMCnsOTg=";
    };
    codex = {
      url = "https://codex-desktop-linux.cachix.org";
      key = "codex-desktop-linux.cachix.org-1:nX/xy6AdK9hQE24A8ALGjkCKj2ObFmcnemiL5Cid4nk=";
    };
    speech = {
      url = "https://fcitx5-vinput.cachix.org";
      key = "fcitx5-vinput.cachix.org-1:XpX3AA6+dDIX4qJhb1QM7sbTwX6/qSlGvW8Z5NK6XdU=";
    };
    nur = {
      url = "https://cache.chumeng.xyz/nur";
      key = "nur:dJh05Op2+iv3GCHoaF2+1FfQtqcUZzf/4v/ZTaLHomY=";
    };
  };
}
