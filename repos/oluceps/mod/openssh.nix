{
  flake.modules.nixos.openssh =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = lib.mkForce false;
          PermitRootLogin = lib.mkForce "prohibit-password";
          UseDns = false;
          X11Forwarding = false;
          KexAlgorithms = [
            "mlkem768x25519-sha256"
            "sntrup761x25519-sha512"
            "sntrup761x25519-sha512@openssh.com"
          ];
          TrustedUserCAKeys = toString (pkgs.writeText "sshCA" config.data.keys.sshCAPubKey);
        };
        authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
        extraConfig = ''
          ClientAliveInterval 60
          ClientAliveCountMax 720
        '';
      };
    };
}
