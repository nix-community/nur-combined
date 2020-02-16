{
  i3gopher = import ./i3gopher;
  tamzen = import ./tamzen.nix;
  paswitch = import ./paswitch.nix;
  LanguageClient-neovim = import ./language-client-neovim.nix;
  base16-shell = import ./base16-shell.nix;
  efm-langserver = import ./efm-langserver;
  markdownlint-cli = import ./markdownlint-cli;
  clip = import ./clip.nix;
  nvflash = import ./nvflash.nix;
  nvidia-vbios-vfio-patcher = import ./nvidia-vbios-vfio-patcher;
  edfbrowser = import ./edfbrowser;
} // (import ./nixos.nix)
// (import ./droid.nix)
// (import ./weechat)
// (import ./crates)
// (import ./programs.nix)
// (import ./linux)
// (import ./matrix)
// (import ./pass)
