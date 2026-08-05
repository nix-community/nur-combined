{ vaculib, vacuModules, ... }:
{
  imports = [
    vacuModules.vacuvmGuest
    vacuModules.sops
  ]
  ++ vaculib.directoryGrabberList ./.;

  vacu.hostName = "quasar2";

  vacuvmGuest.ip = "10.78.77.3";

  system.stateVersion = "26.05";
}
