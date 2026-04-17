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
              initialHashedPassword = lib.mkForce config.data.keys.hashedPasswd;
              openssh.authorizedKeys.keys = authSSHKeys;
            };
            remotebuild = {
              isNormalUser = true;
              createHome = false;
              group = "remotebuild";

              openssh.authorizedKeys.keys = [ config.data.keys.rBuildSshPubKey ];
            };

            ${config.identity.user} = {
              linger = true;
              initialHashedPassword = lib.mkDefault config.data.keys.hashedPasswd;
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
            root.shell = pkgs.fish;
          };
          groups.nixosvmtest = { };
          groups.${config.identity.user} = { };
          groups.remotebuild = { };
        };

    };
}
