{ home-manager
, modules
, pkgs
, nixpkgs
, sync-database
, android-platform-tools }:
let
  sshKeys = import "${nixpkgs}/nixos/tests/ssh-keys.nix" pkgs;
    ssh-config = builtins.toFile "ssh.conf" ''
      UserKnownHostsFile=/dev/null
      StrictHostKeyChecking=no
    '';
  verify-all = pkgs.writeScriptBin "verify-all" ''
    #! ${pkgs.runtimeShell}
    machine=$1
    tmpout=$(mktemp)
    echo test | ${pkgs.keepassxc}/bin/keepassxc-cli ls /home/bob/passwords/db1.kdbx > $tmpout
    echo "Verifying databases for $machine..."
    cat $tmpout
    echo
    testMergedForMissing(){
      if ! grep "$1" $tmpout; then
        echo "Missing $1 for $machine"
        exit 1
      fi
    }
    testMergedForMissing "MyPassAccount" && \
      testMergedForMissing "Sample Entry New Name" && \
      testMergedForMissing "Sample Entry #2" && \
      rm $tmpout

    echo "Verifying archives for $machine..."
    if ! (find /home/bob/passwords/history_backup -maxdepth 1 -name '*.tar.xz' -print -quit | grep backup); then
      echo "Missing backup tar for $machine";
      exit 1
    fi
    backup=$(find /home/bob/passwords/history_backup -maxdepth 1 -name '*.tar.xz' -print -quit | grep backup)
    echo "Content of $backup for $machine: "
    tar -tvf $backup
    testBackupForMissing(){
      if ! (tar -tvf $backup | grep $1); then
        echo "Missing backup $1 file in $machine";
        exit 1
      fi
    }
    testBackupForMissing "/db1.kdbx" && \
      testBackupForMissing "/db_0" && \
      testBackupForMissing "/db_1"
  '';
in
import "${nixpkgs}/nixos/tests/make-test-python.nix" ({ pkgs, ...}: {
  name = "sync-database";
  nodes = let
    usersConfig = { ... }: {
      users.users.bob =
      { isNormalUser = true;
        description = "Bob Foobar";
        password = "foobar";
      };
    };
  in {
    client =
      { ... }: {
        imports = [ "${home-manager}/nixos" usersConfig ];
        environment.systemPackages = with pkgs; [
          android-platform-tools
          verify-all
        ];
        home-manager.users.bob = { pkgs, ... }: {
          imports = [ modules.hmModules.sync-database ];
          manual.manpages.enable = false;
          sync-database = {
            enable = true;
            passwords_directory = "~/passwords";
            backup_history_directory = "~/passwords/history_backup";
            hosts = {
              server1 = {
                user = "bob";
                port = 22;
              };
            };
          };
        };

      };
    server1 =
      { ... }:

      {
        imports = [ usersConfig ]; 
        environment.systemPackages = with pkgs; [ verify-all ];
        services.openssh = {
          enable = true;
          hostKeys = [];
        };

        systemd.services.sshd = {
          serviceConfig.TimeoutStartSec = 2000;
          preStart = ''
            exec >&2
            install -Dm 600 ${./ssh_keys/ssh_host_rsa_key} /etc/ssh/ssh_host_rsa_key
            install -Dm 600 ${./ssh_keys/ssh_host_ed25519_key} /etc/ssh/ssh_host_ed25519_key
          '';
        };

        security.pam.services.sshd.limits =
          [ { domain = "*"; item = "memlock"; type = "-"; value = 1024; } ];
        users.users.bob.openssh.authorizedKeys.keys = [
          sshKeys.snakeOilPublicKey
        ];
      };
  };

  testScript = let
    clientDb1 = ./dbs/db1-client.kdbx;
    server1Db1 = ./dbs/db1-server1.kdbx;
    runAsBob = cmd: "sudo -u bob ${cmd}";
  in ''
    start_all()

    server1.wait_for_unit("sshd", timeout=2000)
    server1.succeed("systemctl --no-pager show sshd | grep Timeout 1>&2")

    with subtest("manual-authkey"):
      client.succeed("${runAsBob "mkdir -m 700 /home/bob/.ssh"}")
      client.succeed(
          '${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f /home/bob/.ssh/id_ed25519 -N ""'
      )
      public_key = client.succeed(
          "${pkgs.openssh}/bin/ssh-keygen -y -f /home/bob/.ssh/id_ed25519"
      )
      public_key = public_key.strip()
      client.succeed("chmod 600 /home/bob/.ssh/id_ed25519")

      server1.succeed("mkdir -m 700 /home/bob/.ssh")
      server1.succeed("echo '{}' > /home/bob/.ssh/authorized_keys".format(public_key))


      client.succeed("cat ${ssh-config} > /home/bob/.ssh/config")
      server1.succeed("cat ${ssh-config} > /home/bob/.ssh/config")

      client.succeed(
        "cat ${sshKeys.snakeOilPrivateKey} > /home/bob/.ssh/id_ecdsa"
      )
      client.succeed("chmod 600 /home/bob/.ssh/id_ecdsa")

      client.succeed("chown -R bob /home/bob/.ssh")
      server1.succeed("chown -R bob /home/bob/.ssh")

      client.wait_for_unit("network.target")

    with subtest("Setup sync-database"):
      client.succeed("${runAsBob "mkdir -p /home/bob/passwords/history_backup"}")
      client.succeed("${runAsBob "cp ${clientDb1} /home/bob/passwords/db1.kdbx"}")
      client.succeed("chown bob /home/bob/passwords/db1.kdbx")
      client.succeed("chmod +w  /home/bob/passwords/db1.kdbx")
      server1.succeed("${runAsBob "mkdir -p /home/bob/passwords/history_backup"}")
      server1.succeed("${runAsBob "cp ${server1Db1} /home/bob/passwords/db1.kdbx"}")
      server1.succeed("chown bob /home/bob/passwords/db1.kdbx")
      server1.succeed("chmod +w  /home/bob/passwords/db1.kdbx")

    client.succeed("touch /home/bob/.ssh/known_hosts 1>&2")
    client.succeed("${runAsBob "ssh server1 'true' 1>&2"}")
    client.succeed("systemctl restart home-manager-bob.service -l 1>&2")
    client.succeed("${runAsBob "systemctl status home-manager-bob.service -l"} 1>&2")
    client.succeed("${runAsBob "cat /home/bob/.config/sync-database.conf"} 1>&2")
  
    client.succeed(
      "${runAsBob "HOME=/home/bob ${sync-database}/bin/sync_database -k /tmp/sync-database-tmp.d -m test -t 200 -d 1>&2"}"
    )
    client.copy_from_vm("/tmp/sync-database-tmp.d", "tempdir")

    client.succeed("verify-all client 1>&2")
    server1.succeed("verify-all server1 1>&2")
    client.copy_from_vm("/home/bob/passwords", "passwords-client")
    # server1.copy_from_vm("/etc/ssh/ssh_host_rsa_key", "ssh_host_rsa_key")
    # server1.copy_from_vm("/etc/ssh/ssh_host_ed25519_key", "ssh_host_ed25519_key")
  '';
})
