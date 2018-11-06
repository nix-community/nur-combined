import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ... }:

{

  name = "custom-hydra-cfg";

  meta.maintainers = with pkgs.stdenv.lib.maintainers; [ ma27 ];

  machine = { pkgs, ... }: {
    imports = [ ../hydra.nix ];
    virtualisation.memorySize = 1024;
    virtualisation.writableStore = true;

    services.nginx.enable = true;

    nix = {
      buildMachines = [{
        hostName = "localhost";
        systems = [ "x86_64-linux" ];
      }];

      binaryCaches = [];
    };

    ma27.hydra = {
      enable = true;
      disallowRestrictedEval = true;
      storeUri = "local";

      notifications.email.enable = true;
      notifications.email.enablePostfix = true;
      notifications.email.sender = "test@localhost";

      vhost.enableProxy = true;
      vhost.name = "localhost";

      users.admin = {
        initialPassword = "test";
        email = "admin@localhost";
        roles = [ "admin" ];
      };

      signing.enable = true;
    };
  };

  testScript = ''
    $machine->start;

    $machine->waitForUnit("hydra-server.service");

    $machine->waitForOpenPort(3000); # ensure Hydra server is up
    $machine->waitForOpenPort(80);   # ensure nginx is started

    subtest "vhost passes requests to hydra (localhost:3000)", sub {
      $machine->succeed("curl --fail localhost");
    };

    subtest "don't alter existing users", sub {
      $machine->succeed("su -l hydra -c \"hydra-create-user admin --password 'evensafer-lol'\"");
      $machine->systemctl("restart hydra-create-users.service");
      $machine->succeed("curl --fail -X POST localhost:3000/login -H \"Origin: http://localhost:3000\" -H \"Accept: application/json\" --data 'username=admin&password=evensafer-lol'");
    };

    subtest "send notifications", sub {
    
    };
  '';

})
