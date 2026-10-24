{
  pkgs,
  ...
}:

{
  # Add environment variables
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
