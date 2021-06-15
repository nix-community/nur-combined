let
  smtpPort = 25;
in
import ./lib/make-test.nix (
  { ... }: {
    name = "smtp-to-sendmail";
    nodes = {
      smtpToSendmail = {
        priegger.services.smtp-to-sendmail.enable = true;
      };
    };

    testScript =
      ''
        with subtest("should start opensmtpd"):
            smtpToSendmail.wait_for_unit("opensmtpd.service")
            smtpToSendmail.wait_for_open_port(${toString smtpPort})
      '';
  }
)
