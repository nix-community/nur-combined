{ ... }: {
  services.beesd.filesystems.root = {
    spec = "/";
    hashTableSizeMB = 1024;
    verbosity = "notice";
  };

  # The upstream unit's CPUWeight only ranks it within system.slice; see build-priority.nix.
  systemd.slices.bees = {
    description = "bees dedup";
    sliceConfig.CPUWeight = "idle";
  };
  systemd.services."beesd@root".serviceConfig.Slice = "bees.slice";
}
