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
        ];
      };

      ${user} = {
        initialHashedPassword = lib.mkDefault data.keys.hashedPasswd;
        isNormalUser = true;
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
        ];
      };
      root.shell = pkgs.fish;
    };
    groups.nixosvmtest = { };

    # mutableUsers = lib.mkForce false;
  };

  security = {
    doas = {
      enable = false;
      wheelNeedsPassword = false;
    };
    sudo = {
      enable = lib.mkForce true;
      # package = pkgs.sudo-rs;
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
