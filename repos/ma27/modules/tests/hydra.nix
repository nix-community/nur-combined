import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ... }:

let

   trivialJob = pkgs.writeTextDir "trivial.nix" ''
     { trivial = builtins.derivation {
         name = "trivial";
         system = "x86_64-linux";
         builder = "/bin/sh";
         args = ["-c" "echo success > $out; exit 0"];
       };
     }
   '';

  createTrivialProject = pkgs.stdenv.mkDerivation {
    name = "create-trivial-project";
    unpackPhase = ":";
    buildInputs = [ pkgs.makeWrapper ];
    installPhase = "install -m755 -D ${./create-trivial-project.sh} $out/bin/create-trivial-project.sh";
    postFixup = ''
      wrapProgram "$out/bin/create-trivial-project.sh" --prefix PATH ":" ${pkgs.stdenv.lib.makeBinPath [ pkgs.curl ]} --set EXPR_PATH ${trivialJob}
    '';
  };

in

{

  name = "custom-hydra-cfg";

  meta.maintainers = with pkgs.stdenv.lib.maintainers; [ ma27 ];

  machine = { pkgs, ... }: {
    imports = [ ../hydra.nix ];
    virtualisation.memorySize = 1024;
    #virtualisation.writableStore = true;

    nix.binaryCaches = [ ];

    time.timeZone = "UTC";

    services.nginx.enable = true;

    environment.systemPackages = [ createTrivialProject pkgs.jq ];

    ma27.hydra = {
      enable = true;
      disallowRestrictedEval = true;

      architectures = [ "x86_64-linux" ];

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

    # inspired by <nixpkgs/nixos/tests/hydra>, ensure that base functionality still works
    # and doesn't break due to additional configuration
    subtest "build pkgs", sub {
      $machine->succeed("create-trivial-project.sh");

      $machine->waitUntilSucceeds('curl -L -s http://localhost:3000/build/1 -H "Accept: application/json" |  jq .buildstatus | xargs test 0 -eq');
    };
  '';

})
