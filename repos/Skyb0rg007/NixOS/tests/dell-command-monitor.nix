{
  name = "dell-command-monitor";
  meta.timeout = 300;

  nodes.machine = {
    services.dell-command-monitor.enable = true;
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("omid.service")
    machine.wait_for_file("/var/opt/omi/run/omiserver.sock")

    with subtest("OMI answers on its local socket"):
      out = machine.succeed("omicli id")
      assert "OMI_Identify" in out, out

    with subtest("Dell providers are registered and load"):
      machine.succeed("test -e /etc/opt/omi/conf/omiregister/root-dcim-sysman/DellSysMgmtProv.reg")
      out = machine.succeed("omicli gc root/dcim/sysman DCIM_Chassis")
      assert "DCIM_Chassis" in out, out
      # Enumerating fails off Dell hardware, but should still load the provider.
      machine.execute("omicli ei root/dcim/sysman DCIM_Chassis")
      machine.succeed("grep -l libDellSysMgmtProv.so /proc/$(pgrep omiagent)/maps")

    with subtest("Mutable state is set up outside the store"):
      machine.succeed("test -f /opt/dell/dcm/conf/Asset.ini -a ! -L /opt/dell/dcm/conf/Asset.ini")
      machine.succeed("test -f /opt/dell/srvadmin/etc/omreg.cfg")
      machine.succeed("test -d /var/lib/dell-command-monitor/hapi/ini")
  '';
}
