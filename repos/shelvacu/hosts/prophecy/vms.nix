{ vacuModules, ... }: {
  imports = [ vacuModules.qemu-vm ];

  # Routed (no bridge): each VM's tap gets the gateway IP and a /32 host route.
  # Forwarding is open by default (networking.firewall.filterForward = false)
  # and IP forwarding is already enabled via networking.nat.enable = true.
  # The router carries a static route: 10.78.77.0/24 via prophecy's LAN IP.
  vacu.vmNet = {
    enable = true;
    gateway = "10.78.77.1";
  };

  vacu.qemuVMs.vavm = {
    mac = "52:54:00:78:50:02";
    address = "10.78.77.2";
    baseMem = 4096;
    maxMem = 16384;
    dimmSlots = 4;
    cpus = 4;
  };

  vacu.qemuVMs.savm = {
    mac = "11:cc:58:c8:85:36";
    address = "10.78.77.4";
    baseMem = 4096;
    maxMem = 16384;
    dimmSlots = 4;
    cpus = 4;
  };

  vacu.qemuVMs.quasar2 = {
    mac = "fc:49:81:42:20:38";
    address = "10.78.77.3";
    baseMem = 1024;
    maxMem = 16384;
    dimmSlots = 4;
    cpus = 2;
  };
}
