{ vaculib, vacuModules, ... }: {
  imports = [
    vacuModules.vacuvmGuest
    vacuModules.sops
  ]
  ++ vaculib.directoryGrabberList ./.;

  vacu.hostName = "quasar2";

  vacuvmGuest.ip = "10.78.77.3";
  vacuvmGuest.ipv6 = "2602:fce8:106:10::3";
  vacuvmGuest.ipv6Gateway = "2602:fce8:106:10::1";

  system.stateVersion = "26.05";
}
