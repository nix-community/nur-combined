{
  ## Todo: write out the below - need to rework networking module.
  networking = {
    wireless.enable = false;
    hostId = "acd009f4";
    hostName = "dragonite";
    useDHCP = false;
    interfaces.enp9s0.useDHCP = true;

    firewall = {
      ## Todo: remove below as they can be abstracted into microvms
      # For reference:
      # 5900: VNC (need to kill)
      # 8200: Duplicati
      allowedTCPPorts = [ 5900 8200 ];
    };
  };
}
