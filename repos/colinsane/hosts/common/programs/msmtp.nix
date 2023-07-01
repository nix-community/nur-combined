# docs: <https://nixos.wiki/wiki/Msmtp>
# validate with e.g.
# - `echo -e "Content-Type: text/plain\r\nSubject: Test\r\n\r\nHello World" | sendmail test@uninsane.org`
{ config, lib, ... }:

{
  sane.programs.msmtp = {
    secrets.".config/msmtp/password.txt" = ../../../secrets/common/msmtp_password.txt.bin;
  };

  programs.msmtp = lib.mkIf config.sane.programs.msmtp.enabled {
    enable = true;
    accounts = {
      default = {
        auth = true;
        tls = true;
        tls_starttls = false;  # needed else sendmail hangs
        from = "Colin <colin@uninsane.org>";
        host = "mx.uninsane.org";
        user = "colin";
        passwordeval = "cat ~/.config/msmtp/password.txt";
      };
    };
  };
}
