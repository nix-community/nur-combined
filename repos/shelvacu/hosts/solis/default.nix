{ vaculib, vacuModules, ... }:
{
  imports = [
    vacuModules.sops
    vacuModules.archived-user
  ] ++ vaculib.directoryGrabberList ./.;
  options.vacu.this = vaculib.mkOutOptions {
    ip4 = "89.213.174.171";
    ip6 = "2a0f:9400:7e11:cd44::1";
    ip6net = "2a0f:9400:7e11:cd44::1/64";
  };
  config = {
    vacu.hostName = "solis";
    vacu.shell.color = "red";
    networking.domain = "dis8.net";
    vacu.systemKind = "minimal";

    hardware.enableAllFirmware = false;
    hardware.enableRedistributableFirmware = false;

    # networking.interfaces."ens3".useDHCP = false;
    services.openssh.enable = true;

    system.stateVersion = "25.05";

    vacu.git.enable = true;
  };
}
