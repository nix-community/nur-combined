{
  services.btrbk.instances.btrbk = {
    onCalendar = "daily";
    settings = {
      snapshot_preserve = "7d 2w";
      snapshot_preserve_min = "latest";

      target_preserve = "7d 2w";
      target_preserve_min = "latest";

      volume = {
        "/home/" = {
          subvolume = {
            "." = {
              snapshot_create = "always";
            };
          };
          snapshot_dir = "/.snapshots/";
        };
      };
    };
  };
}
