{
  flake.modules.nixos.users =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.userborn.enable = true;

      # linger-users.service from nixos/modules/config/users-groups.nix only
      # orders itself after systemd-logind.service. userborn.service is
      # restarted on every switch that changes the user list (restartTriggers),
      # so both land in the same switch transaction and linger-users can win the
      # race: loginctl then dies with
      #   Failed to look up user <name>: No such process
      # and start-limit-hits. Everything that Wants=linger-users.service stays
      # down with it (e.g. rootless oci-containers via `podman.user`).
      # userborn aliases itself to systemd-sysusers.service, so ordering after
      # the alias covers hosts that use systemd-sysusers instead.
      systemd.services.linger-users = lib.mkIf config.users.manageLingering {
        wants = [ "userborn.service" ];
        after = [
          "userborn.service"
          "systemd-sysusers.service"
        ];
      };

      users =
        let
          authSSHKeys = with config.data.keys; [
            sshPubKey2
            skSshPubKey
            skSshPubKey2
          ];
        in
        {
          mutableUsers = false;
          users = {
            nixosvmtest = {
              group = "nixosvmtest";
              isSystemUser = true;
              initialPassword = "test";
            };

            root = {
              hashedPassword = lib.mkForce config.data.keys.hashedPasswd;
              openssh.authorizedKeys.keys = authSSHKeys;
            };

            ${config.identity.user} = {
              linger = true;
              hashedPassword = lib.mkDefault config.data.keys.hashedPasswd;
              subUidRanges = [
                {
                  startUid = 100000;
                  count = 65536;
                }
              ];
              subGidRanges = [
                {
                  startGid = 100000;
                  count = 65536;
                }
              ];
              # home = "/home/${user}";
              # group = user;
              isNormalUser = true;
              # isSystemUser = true;
              uid = 1000;
              extraGroups = [
                "wheel"
                "kvm"
                "adbusers"
                "wireshark"
                "tss"
              ];
              shell = pkgs.fish;

              openssh.authorizedKeys.keys = authSSHKeys;
            };
          };
          groups.nixosvmtest = { };
          groups.${config.identity.user} = { };
          groups.remotebuild = { };
        };

    };
}
