{
  vaculib,
  vacuModules,
  ...
}:
{
  imports = [ vacuModules.agentVm ] ++ vaculib.directoryGrabberList ./.;

  vacu.hostName = "savm";

  system.stateVersion = "25.11";

  vacuvmGuest.ip = "10.78.77.4";
  vacuvmGuest.ipv6 = "2602:fce8:106:10::4";
}
