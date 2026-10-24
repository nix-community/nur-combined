{
  nixosModules,
  ...
}:
let
  sshPolicy = import ../../lib/ssh-policy.nix;
in
{
  imports = [ nixosModules.profiles.core ];

  networking.firewall.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 3939 ];
    openFirewall = true;
    allowSFTP = false;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;

      AllowTcpForwarding = "yes";
      AllowAgentForwarding = "no";
      AllowStreamLocalForwarding = "no";
      AuthenticationMethods = "publickey";

      Ciphers = sshPolicy.ciphers;
      KexAlgorithms = sshPolicy.kexAlgorithms;
      Macs = sshPolicy.macs;
      HostKeyAlgorithms = builtins.concatStringsSep "," sshPolicy.keyAlgorithms;
      PubkeyAcceptedAlgorithms = builtins.concatStringsSep "," sshPolicy.keyAlgorithms;
    };
  };
}
