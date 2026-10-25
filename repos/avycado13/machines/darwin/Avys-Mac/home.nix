{
  home-manager.users.avy.dots = {
    shell = {
      enable = true;
      # profiling.enable = true;
    };

    editor.enable = true;
    ssh = {
      enable = true;
      zmx.enable = true;
    };
    git = {
      enable = true;
      wut.enable = true;
    };
    terminal = {
      enable = true;
      ghostty.enable = true;
    };

    gpg.enable = true;
    devenv = {
      enable = true;
      asic.enable = true;
      ai.enable = true;
      ai.codex.enable = true;
    };
    theme.enable = true;
    syncthing.enable = true;
    restic.enable = true;
    irc.enable = true;
    media = {
      enable = true;
      inkscape.enable = true;
    };
  };
}
