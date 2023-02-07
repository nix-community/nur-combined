{
  fileSystems = let
    fsType = "zfs";
    options = [ "nofail" ];
  in {
    "/mnt/zfs" = {
      device = "tank";
      inherit fsType options;
    };

    "/mnt/zfs/storage" = {
      device = "tank/storage";
      inherit fsType options;
    };

    "/mnt/zfs/cache" = {
      device = "tank/cache";
      inherit fsType options;
    };

    "/mnt/zfs/containers" = {
      device = "tank/containers";
      inherit fsType options;
    };

    "/mnt/zfs/isos" = {
      device = "tank/isos";
      inherit fsType options;
    };

    "/mnt/zfs/tv" = {
      device = "tank/tv";
      inherit fsType options;
    };

    "/mnt/zfs/backup" = {
      device = "tank/backup";
      inherit fsType options;
    };

    "/mnt/zfs/personal_video" = {
      device = "tank/personal_video";
      inherit fsType options;
    };

    "/mnt/zfs/work" = {
      device = "tank/work";
      inherit fsType options;
    };

    "/mnt/zfs/games" = {
      device = "tank/games";
      inherit fsType options;
    };

    "/mnt/zfs/movies" = {
      device = "tank/movies";
      inherit fsType options;
    };

    "/mnt/zfs/nextcloud" = {
      device = "tank/nextcloud";
      inherit fsType options;
    };

    "/mnt/zfs/music" = {
      device = "tank/music";
      inherit fsType options;
    };

    "/mnt/zfs/photos" = {
      device = "tank/photos";
      inherit fsType options;
    };

    "/mnt/zfs/downloads" = {
      device = "tank/downloads";
      inherit fsType options;
    };

    "/mnt/zfs/databases" = {
      device = "tank/databases";
      inherit fsType options;
    };

    "/mnt/zfs/home_assistant" = {
      device = "tank/home_assistant";
      inherit fsType options;
    };

    "/mnt/zfs/logs" = {
      device = "tank/logs";
      inherit fsType options;
    };
  };
}
