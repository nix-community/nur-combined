{ reIf, lib, ... }:
reIf {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkForce false;
      PermitRootLogin = lib.mkForce "prohibit-password";
      UseDns = false;
      X11Forwarding = false;
      KexAlgorithms = [
        # pqc
        "mlkem768x25519-sha256"
        "sntrup761x25519-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
    };
    authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
    extraConfig = ''
      ClientAliveInterval 60
      ClientAliveCountMax 720
    '';
  };
}
