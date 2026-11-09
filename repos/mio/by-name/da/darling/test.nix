{ darling }:

{
  name = "darling";

  nodes.machine = {
    imports = [ ../../../modules/darling.nix ];
    programs.darling = {
      enable = true;
      package = darling;
    };
    users.users.alice = {
      isNormalUser = true;
      createHome = true;
    };
    virtualisation.memorySize = 4096;
    virtualisation.cores = 2;
  };

  testScript = ''
    from datetime import timedelta

    machine.start()
    machine.wait_for_unit("multi-user.target")
    output = machine.succeed("su - alice -c '/run/wrappers/bin/darling shell /bin/echo darling-ok'", timeout=timedelta(seconds=180))
    assert "darling-ok" in output, output
    output = machine.succeed("su - alice -c '/run/wrappers/bin/darling shell /usr/bin/uname -s'", timeout=timedelta(seconds=60))
    assert "Darwin" in output, output
  '';
}
