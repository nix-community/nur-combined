{ pkgs
, lib
, config
, ...
}:

{
  systemd.services.btrfs-scrub-persist.serviceConfig.ExecStopPost =
    lib.genNtfyMsgScriptPath "tags red_circle prio high" "error" "btrfs scrub failed on hastur";

  services = {
    bpftune.enable = true;

    journald.extraConfig =
      ''
        SystemMaxUse=1G
      '';

    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/persist" ];
    };
  };
}
