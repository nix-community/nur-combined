{
  systemd.tmpfiles.settings.whatever."/var/lib/syncthing".d = {
    mode = "0700";
    user = "shelvacu";
    group = "root";
  };
  services.syncthing = {
    enable = true;
    user = "shelvacu";
    group = "users";
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
    settings.options = {
      autoUpgradeIntervalH = 0;
      crashReportingEnabled = false;
      urAccepted = -1;
    };
  };
}
