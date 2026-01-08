{
  config,
  pkgs,
  machine,
  ...
}:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "shiroki";
  home.homeDirectory = "/home/shiroki";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  catppuccin = {
    enable = true;
    cache.enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = "
      set fish_greeting # Disable greeting
    ";
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bat.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      custom_cpu_name =
        {
          "o6n" = "CIX P1";
        }
        .${machine} or "";
    };
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf.enable = true;

  programs.gitui.enable = true;

  programs.zellij.enable = true;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
