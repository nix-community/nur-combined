{
  pkgs,
  user,
  data,
  lib,
  ...
}:
{
  users = {
    users = {
      nixosvmtest = {
        group = "nixosvmtest";
        isSystemUser = true;
        initialPassword = "test";
      };

      root = {
        initialHashedPassword = lib.mkForce data.keys.hashedPasswd;
        openssh.authorizedKeys.keys = with data.keys; [
          sshPubKey
          skSshPubKey
          skSshPubKey2
        ];
      };

      ${user} = {
        initialHashedPassword = lib.mkDefault data.keys.hashedPasswd;
        # home = "/home/${user}";
        # group = user;
        isNormalUser = true;
        # isSystemUser = true;
        uid = 1000;
        extraGroups = [
          "wheel"
          "kvm"
          "adbusers"
          "docker"
          "wireshark"
          "tss"
          "podman"
        ];
        shell = pkgs.fish;

        openssh.authorizedKeys.keys = with data.keys; [
          sshPubKey
          skSshPubKey
          skSshPubKey2
        ];
      };
      root.shell = pkgs.fish;
    };
    groups.nixosvmtest = { };
    groups.${user} = { };
  };

  security = {
    doas = {
      enable = false;
      wheelNeedsPassword = false;
    };
    sudo-rs = {
      enable = true;
      extraRules = [
        {
          users = [ "${user}" ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };
}
