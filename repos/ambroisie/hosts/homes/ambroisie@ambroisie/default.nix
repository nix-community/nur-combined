# Google Cloudtop configuration
{ ... }:
{
  # Google specific configuration
  home.homeDirectory = "/usr/local/google/home/ambroisie";

  home.sessionVariables = {
    # Some tooling (e.g: SSH) need to use this library
    LD_PRELOAD = "/lib/x86_64-linux-gnu/libnss_cache.so.2\${LD_PRELOAD:+:}$LD_PRELOAD";
  };

  my.home = {
    # I don't need a GPG agent
    gpg.enable = false;
  };
}
