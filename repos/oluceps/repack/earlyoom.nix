{ reIf, ... }:
reIf {
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
  };
}
