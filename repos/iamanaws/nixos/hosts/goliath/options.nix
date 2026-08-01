{
  device = {
    system = "x86_64-linux";
    hostname = "goliath";
    profile = "desktop";
    openpgp.enable = true;
    users = [
      {
        name = "iamanaws";
        groups = [
          "wheel"
          "input"
        ];
      }
      "zsheen"
    ];
    compositors = [
      "gnome"
      "hyprland"
    ];
    stateVersion = "25.11";
    timezone = "America/Tijuana";
    locale = "en_US.UTF-8";
  };
}
