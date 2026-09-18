{ vacuModules, ... }: {
  imports = [ vacuModules.qemu-vm ];

  # Routed (no bridge): each VM's tap gets the gateway IP and a /32 host route.
  # Forwarding is open by default (networking.firewall.filterForward = false)
  # and IP forwarding is already enabled via networking.nat.enable = true.
  # Policy routing sends guest internet traffic through wg-doof.
  vacu.vmNet = {
    enable = true;
    v4Prefix = "10.78.77";
    v6Prefix = "2602:fce8:106:10::";
  };

  vacu.qemuVMs = {
    vavm = {
      tag = 2;
      baseMem = 16 * 1024;
      maxMem = 128 * 1024;
      dimmSlots = 4;
      cpus = 4;
    };

    savm = {
      tag = 4;
      baseMem = 16 * 1024;
      maxMem = 128 * 1024;
      dimmSlots = 4;
      cpus = 4;
      shares.javadrive = {
        source = "/propdata/trip/ffuts/stuff/java-scribbles-drives";
        readOnly = true;
      };
      shares.bigdata.source = "/propdata/vm-bigdata/savm";
    };

    quasar2 = {
      tag = 3;
      baseMem = 1 * 1024;
      maxMem = 16 * 1024;
      dimmSlots = 4;
      cpus = 2;
    };

    jv-shel = {
      tag = 5;
      baseMem = 1 * 1024;
      maxMem = 16 * 1024;
      dimmSlots = 4;
      cpus = 2;
    };
  };
}
