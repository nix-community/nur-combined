import ./lib/make-test.nix (
  { lib, ... }:
    let
      nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
    in
      {
        name = "profiles";
        nodes = {
          common = {
            imports = [
              ../modules/profiles/common.nix
            ]
            ++ lib.attrValues nur-no-pkgs.repos.kampka.modules
            ;
          };
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

            with subtest("common starts"):
                common.wait_for_unit("multi-user.target")
                checkCommonProperties(common)

            with subtest("desktop starts"):
                desktop.wait_for_unit("multi-user.target")
                checkCommonProperties(desktop)

                desktop.require_unit_state("display-manager.service")
                desktop.require_unit_state("NetworkManager.service")

            with subtest("headless starts"):
                headless.wait_for_unit("multi-user.target")
                checkCommonProperties(headless)
          '';
      }
)
