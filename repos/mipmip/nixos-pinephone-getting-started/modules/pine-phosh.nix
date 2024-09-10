{ ... }:
{
  services.xserver.desktopManager.phosh = {
    enable = true;
    user = "pim";
    group = "users";
  };

  environment.variables = {
    # Qt apps won't always start unless this env var is set
    QT_QPA_PLATFORM = "wayland";
  };
}
