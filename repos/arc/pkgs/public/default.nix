{
  i3gopher = import ./i3gopher;
  inherit (import ./yggdrasil) yggdrasil yggdrasilctl;
  tamzen = import ./tamzen.nix;
  lorri = import ./lorri.nix;
  paswitch = import ./paswitch.nix;
  LanguageClient-neovim = import ./language-client-neovim.nix;
  base16-shell = import ./base16-shell.nix;
  urxvt_osc_52 = import ./urxvt-osc-52.nix;
  urxvt_xresources_256 = import ./urxvt-xresources-256.nix;
  efm-langserver = import ./efm-langserver;
} // (import ./nixos.nix)
// (import ./droid.nix)
// (import ./weechat.nix)
// (import ./crates)
// (import ./programs.nix)
// (import ./linux)
// (import ./matrix)
