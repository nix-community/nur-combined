{
  flake.modules.nixos.earlyoom = {
    services.smartd.notifications.systembus-notify.enable = true;
    services.earlyoom = {
      enable = true;
      enableNotifications = true;
      extraArgs = [
        "--avoid"
        "bird"
      ];
    };
  };
}
