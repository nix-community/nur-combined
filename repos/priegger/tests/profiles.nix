import ./lib/make-test.nix (
  { lib, ... }:
    let
      nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
    in
      {
        name = "profiles";
        nodes = {
          desktop = {
            imports = [
              ../modules/profiles/desktop.nix
            ]
            ++ lib.attrValues nur-no-pkgs.repos.kampka.modules
            ;
          };
          headless = {
            imports = [
              ../modules/profiles/headless.nix
            ]
            ++ lib.attrValues nur-no-pkgs.repos.kampka.modules
            ;
          };
        };

        testScript =
          ''
            def checkCommonProperties(machine):
                # programs that should be there
                for program in [
                    "autojump",
                    "bash",
                    "cryptsetup",
                    "curl",
                    "direnv",
                    "file",
                    "git",
                    "gpg",
                    "htop",
                    "kill",
                    "killall",
                    "lorri",
                    "man",
                    "ps",
                    "pv",
                    "pwgen",
                    "ssh",
                    "tcpdump",
                    "tree",
                    "vim",
                    "wg",
                    "wget",
                ]:
                    machine.succeed("type -p {} 1>&2".format(program))

                # services that should be running
                machine.wait_for_unit("multi-user.target")

                machine.require_unit_state("fail2ban")

                machine.succeed("lorri --version")
                machine.succeed("test -f /etc/systemd/user/lorri.service")
                machine.succeed("test -f /etc/systemd/user/lorri.socket")

                machine.require_unit_state("sshd")
                machine.wait_for_open_port("22")

                machine.require_unit_state("chronyd")

                machine.require_unit_state("dnsmasq")
                machine.require_unit_state("stubby")

                machine.require_unit_state("prometheus")
                machine.require_unit_state("prometheus-node-exporter")

                machine.require_unit_state("tor")
                machine.require_unit_state("prometheus-tor-exporter")


            start_all()

            with subtest("desktop starts"):
                checkCommonProperties(desktop)

                # programs that should be there
                for program in ["gnome-tweaks"]:
                    desktop.succeed("type -p {} 1>&2".format(program))

                # programs that should NOT be there
                for program in [
                    "epiphany",
                    "evolution",
                    "geary",
                    "gnome-software",
                    "rygel",
                    "totem",
                    "tracker",
                ]:
                    desktop.fail("type -p {} 1>&2".format(program))

                # services that should be running
                desktop.require_unit_state("display-manager.service")
                desktop.require_unit_state("NetworkManager.service")

            with subtest("headless starts"):
                checkCommonProperties(headless)
          '';
      }
)
