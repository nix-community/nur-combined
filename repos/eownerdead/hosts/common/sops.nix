{ config, ... }: {
  sops = {
    age.sshKeyPaths = [ ];
    gnupg = {
      home = "/var/lib/sops";
      sshKeyPaths = [ ];
    };
    secrets.noobuserPassword = {
      sopsFile = ../../users/noobuser/sops.yaml;
      key = "password";
      neededForUsers = true;
    };
  };
}
