let
  smtpPort = 25;
in
import ./lib/make-test.nix (
  { ... }: {
    name = "opensmtpd-relay";
    nodes.machine = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ mailutils ];

      services.mailhog.enable = true;

      networking.domain = "test.tld";
      priegger.services.opensmtpd-relay = {
        enable = true;
        hostName = "localhost:1025";
        authSecretsFile = toString (pkgs.writeText "secrets" ''
          upstream test-username:test-password
        '');
        mailTo = "foo@bar.baz";
      };
    };

    testScript =
      ''
        with subtest("should start mailhog"):
            machine.wait_for_unit("mailhog.service")

        with subtest("should start opensmtpd"):
            machine.wait_for_unit("opensmtpd.service")
            machine.wait_for_open_port(${toString smtpPort})

        machine.succeed('echo -e "Subject: test-subject\n\ntest-body" | mail test-rcpt')
        machine.wait_until_succeeds('journalctl -u opensmtpd | grep "mta error reason=TLS required but not supported by remote host"')

        # TODO: Testing in mailhog does not work because the tls connection fails.
        # machine.succeed(
        #   "curl --fail http://127.0.0.1:8025/api/v2/messages | tee /dev/stderr"
        # )
      '';
  }
)
