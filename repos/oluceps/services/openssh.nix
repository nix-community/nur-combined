{ pkgs, ... }:
let
  inherit (pkgs) lib;
in
{
  enable = true;
  settings = {
    PasswordAuthentication = lib.mkForce false;
    PermitRootLogin = lib.mkForce "prohibit-password";
    UseDns = false;
    X11Forwarding = false;
  };
  authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
  extraConfig = ''
    ClientAliveInterval 60
    ClientAliveCountMax 720
  '';
}
