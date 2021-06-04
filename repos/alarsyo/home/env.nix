{ config, ... }:
{
  home.sessionPath = [
    "${config.xdg.configHome}/emacs/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];
}
