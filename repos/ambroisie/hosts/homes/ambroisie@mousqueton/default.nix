# Google Cloudtop configuration
{ lib, pkgs, ... }:
{
  # Google specific configuration
  home.homeDirectory = "/usr/local/google/home/ambroisie";

  # Some tooling (e.g: SSH) need to use this library
  home.sessionVariables = {
    LD_PRELOAD = "/lib/x86_64-linux-gnu/libnss_cache.so.2\${LD_PRELOAD:+:}$LD_PRELOAD";
  };

  systemd.user.sessionVariables = {
    LD_PRELOAD = "/lib/x86_64-linux-gnu/libnss_cache.so.2\${LD_PRELOAD:+:}$LD_PRELOAD";
  };

  programs.git.package = lib.mkForce pkgs.emptyDirectory;

  services.gpg-agent.enable = lib.mkForce false;

  # I use scripts that use the passthrough sequence often on this host
  my.home.tmux.enablePassthrough = true;

  # HTerm uses `xterm-256color` as its `$TERM`, so use that here
  my.home.tmux.trueColorTerminals = [ "xterm-256color" ];
}
