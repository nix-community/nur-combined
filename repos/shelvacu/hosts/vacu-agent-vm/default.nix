{
  vaculib,
  vacuModules,
  ...
}:
{
  imports = [ vacuModules.agentVm ] ++ vaculib.directoryGrabberList ./.;

  vacu.hostName = "vacu-agent-vm";
  system.stateVersion = "25.11";

  fileSystems."/bigdata" = {
    device = "bigdata";
    fsType = "virtiofs";
    options = [
      "nofail"
      "X-mount.mkdir"
    ];
  };

  vacuvmGuest.ip = "10.78.77.2";
  vacuvmGuest.ipv6 = "2602:fce8:106:10::2";
}
