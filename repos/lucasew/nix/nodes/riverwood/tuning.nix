{ pkgs, ... }:
{
  nix.settings = {
    min-free = 1 * 1024 * 1024 * 1024;
    max-free = 10 * 1024 * 1024 * 1024;
  };

  # services.auto-cpufreq.enable = true;
  # services.tlp.enable = true;

  hardware = {
    bluetooth.enable = true;
  };

  # não deixar explodir
  nix.settings.max-jobs = 3;
}
