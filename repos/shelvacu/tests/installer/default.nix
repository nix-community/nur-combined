{ pkgs, ... }:
let
  ca = pkgs.runCommand "installer-test-ca" { nativeBuildInputs = [ pkgs.openssh ]; } ''
    mkdir "$out"
    ssh-keygen -q -t ed25519 -N "" -f "$out/key"
    echo localhost > "$out/principals"
    echo +52w > "$out/validity"
  '';
  firewall = pkgs.callPackage ../../scripts/make-installer/firewall.nix { };
  kernel = pkgs.writeText "fixture-kernel" "kernel";
  initrd = pkgs.writeText "fixture-initrd" "initrd";
  settings = pkgs.writeText "installer-test-settings.json" (
    builtins.toJSON {
      caPublic = "${ca}/key.pub";
      pxeKernel = toString kernel;
      pxeInitrd = toString initrd;
      pxeCmdline = "init=/fixture/init console=ttyS0";
      pixiecore = pkgs.lib.getExe pkgs.pixiecore;
      firewall = pkgs.lib.getExe firewall;
    }
  );
  tool = pkgs.writeShellApplication {
    name = "installer-test";
    runtimeInputs = with pkgs; [
      python3
      openssh
      cpio
      systemd
    ];
    text = ''
      exec python3 ${../../scripts/make-installer/make-installer.py} ${settings} --ca-key ${ca}/key "$@"
    '';
  };
  common = {
    networking.firewall.enable = true;
    environment.systemPackages = with pkgs; [
      firewall
      tool
      nftables
      iptables
      curl
    ];
  };
in
{
  name = "installer";
  nodes = {
    nft = { config, ... }: {
      imports = [
        common
        ../../hosts/installer/common/ssh.nix
      ];
      networking.nftables.enable = true;
      services.openssh.enable = true;
      services.openssh.settings.PermitRootLogin = "yes";
      users.users.root.openssh.authorizedKeys.keyFiles = [ "${ca}/key.pub" ];
      virtualisation.directBoot.initrd = toString (
        pkgs.runCommand "installer-test-initrd"
          {
            nativeBuildInputs = [
              pkgs.cpio
              pkgs.python3
            ];
          }
          ''
            mkdir -m 0700 installer-ssh-ca
            cp ${ca}/{key,principals,validity} installer-ssh-ca/
            chmod 0600 installer-ssh-ca/*
            printf '%s\n' installer-ssh-ca installer-ssh-ca/{key,principals,validity} | cpio -o -H newc > ca.cpio
            cp ${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile} "$out"
            chmod u+w "$out"
            python3 - <<'PYTHON'
            import os
            from pathlib import Path
            with Path(os.environ["out"]).open("ab") as stream:
                stream.write(b"\0" * (-stream.tell() % 4))
                stream.write(Path("ca.cpio").read_bytes())
            PYTHON
          ''
      );
    };
    ipt = {
      imports = [ common ];
      networking.nftables.enable = false;
    };
  };
  testScript = ''
    import shlex

    start_all()
    nft.wait_for_unit("sshd.service")
    ipt.wait_for_unit("multi-user.target")
    key_path = "/run/installer-ssh/ssh_host_ed25519_key"
    first_key = nft.succeed(f"cat {key_path}.pub")
    nft.succeed(f"ssh-keygen -L -f {key_path}-cert.pub | grep localhost")
    nft.succeed("journalctl -b -u installer-ssh | grep 'SHA256:'")
    assert nft.succeed(f"stat -c %a {key_path}").strip() == "600"
    nft.succeed("echo '@cert-authority localhost '$(cat ${ca}/key.pub) > /tmp/known_hosts")
    nft.succeed("install -m 0600 ${ca}/key /root/client-key")
    ssh = "ssh -o StrictHostKeyChecking=yes -o UserKnownHostsFile=/tmp/known_hosts -o IdentitiesOnly=yes -i /root/client-key localhost true"
    nft.succeed(ssh)
    nft.succeed("systemctl restart sshd")
    assert nft.succeed(f"cat {key_path}.pub") == first_key
    nft.shutdown()
    nft.start()
    nft.wait_for_unit("sshd.service")
    assert nft.succeed(f"cat {key_path}.pub") != first_key
    nft.succeed("test -s /run/installer-ssh-ca/key")
    nft.succeed("echo '@cert-authority localhost '$(cat ${ca}/key.pub) > /tmp/known_hosts")
    nft.succeed(ssh)
    nft.succeed("systemctl stop sshd installer-ssh; mv /run/installer-ssh-ca /run/ca-hidden")
    nft.fail("systemctl start sshd")
    nft.succeed("mv /run/ca-hidden /run/installer-ssh-ca; systemctl reset-failed; systemctl start sshd")

    for machine, backend in [(nft, "nftables"), (ipt, "iptables")]:
        assert machine.succeed("installer-pxe-firewall probe").strip() == backend
        # Keep an independent temporary rule to check that cleanup owns its rules.
        machine.succeed(f"installer-pxe-firewall open {backend} installer-pxe-abcdef 8080")
        machine.succeed("installer-test pxe --firewall open > /tmp/pxe.log 2>&1 & echo $! > /tmp/pxe.pid")
        machine.wait_for_open_port(8080)
        script = machine.succeed("curl --fail 'http://127.0.0.1:8080/_/ipxe?mac=52:54:00:00:00:01&arch=1'")
        assert "init=/fixture/init" in script and "initrd=initrd0" in script
        initrd_url = next(line.split()[3] for line in script.splitlines() if line.startswith("initrd "))
        machine.succeed(f"curl --fail {shlex.quote(initrd_url)} -o /tmp/served-initrd")
        machine.succeed("mkdir /tmp/served-ca; tail -c +9 /tmp/served-initrd | ${pkgs.cpio}/bin/cpio -id --directory=/tmp/served-ca")
        machine.succeed("cmp /tmp/served-ca/installer-ssh-ca/key ${ca}/key")
        machine.succeed("grep -q 'init=/fixture/init' /proc/$(pgrep -x pixiecore)/cmdline")
        machine.succeed("kill -TERM $(cat /tmp/pxe.pid)")
        machine.wait_until_fails("pgrep -x pixiecore")
        rules_cmd = "nft list chain inet nixos-fw input-allow" if backend == "nftables" else "iptables -S nixos-fw"
        machine.wait_until_succeeds(f"test $({rules_cmd} | grep -c installer-pxe-) -eq 2", timeout=60)
        rules = machine.succeed(rules_cmd)
        assert rules.count("installer-pxe-") == 2, rules
        machine.succeed(f"installer-pxe-firewall close {backend} installer-pxe-abcdef 8080")
        assert "installer-pxe-" not in machine.succeed(rules_cmd)
        # A failed server startup must also run ExecStopPost.
        machine.succeed("installer-test pxe --firewall open > /tmp/pxe.log 2>&1 & echo $! > /tmp/pxe.pid")
        machine.wait_for_open_port(8080)
        machine.fail("installer-test pxe --firewall open")
        machine.succeed("kill -KILL $(pgrep -x pixiecore)")
        machine.wait_until_fails("pgrep -x pixiecore")
        machine.wait_until_succeeds(f"! {rules_cmd} | grep installer-pxe-")
  '';
}
