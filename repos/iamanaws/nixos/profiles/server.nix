{
  nixosModules,
  ...
}:

{
  imports = [ nixosModules.profiles.core ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [ 53 ];
  };

  services.openssh = {
    enable = true;
    ports = [ 3939 ];
    allowSFTP = false;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;

      "AllowTcpForwarding" = "yes";
      "AllowAgentForwarding" = "no";
      "AllowStreamLocalForwarding" = "no";
      "AuthenticationMethods" = "publickey";

      Ciphers = [
        "aes128-ctr"
        "aes128-gcm@openssh.com"
        "aes256-ctr,aes192-ctr"
        "aes256-gcm@openssh.com"
      ];
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
      Macs = [
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-512"
        "hmac-sha2-512-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };
  };
}
