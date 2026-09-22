{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.vacu.pbx;

  # Both guarded files are sops templates, i.e. they only exist once
  # sops-install-secrets has successfully decrypted secrets/hosts/pbxvm.yaml.
  # When that fails, each dependent service fails in its own quiet, misleading
  # way:
  #
  #   - asterisk `#include`s the pjsip secrets, and asterisk discards the
  #     *entire* config file when an include is missing — so a PBX with no
  #     credentials comes up as a PBX with no SIP transports at all, and the one
  #     line saying why scrolls past mid-boot among a hundred unrelated
  #     "unable to load config" messages.
  #   - atftpd logs "Serving SEP<MAC>.cnf.xml" when it receives the *request*,
  #     before it opens anything (tftpd.c, GET_RRQ), so a missing config file
  #     looks exactly like a working one in the journal while the phone retries
  #     forever.
  #
  # Refuse to start instead, name the file, and retry so the service heals by
  # itself once the secret turns up.
  guard =
    {
      unit,
      user,
      files,
    }:
    pkgs.writeShellScript "${unit}-require-secrets" ''
      missing=0
      for f in ${lib.escapeShellArgs files}; do
        if ! ${pkgs.util-linux}/bin/runuser -u ${user} -- ${pkgs.coreutils}/bin/test -r "$f"; then
          echo "${unit}: $f is missing or unreadable by ${user}" >&2
          missing=1
        fi
      done
      if [ "$missing" -ne 0 ]; then
        echo "${unit}: the file(s) above are sops templates that have not been rendered." >&2
        echo "${unit}: sops-install-secrets could not decrypt secrets/hosts/pbxvm.yaml -- most" >&2
        echo "${unit}: likely it is not yet encrypted to this host's key. See docs/pbxvm.md," >&2
        echo "${unit}: 'Finish the secrets'." >&2
        exit 1
      fi
    '';

  # A sops placeholder is substituted literally, so a password chosen without
  # regard for where it lands can quietly corrupt the file that carries it.
  # Neither failure looks like a password problem from the outside, so check the
  # rendered files rather than trusting whoever ran `sops`. Lengths and verdicts
  # only — never echo the value.
  phoneConfig = config.sops.templates."SEP${cfg.phoneMac}.cnf.xml".path;
  checkPhonePassword = pkgs.writeShellScript "atftpd-check-phone-password" ''
    pw=$(${pkgs.gnused}/bin/sed -n 's:.*<authPassword>\(.*\)</authPassword>.*:\1:p' ${lib.escapeShellArg phoneConfig})
    rc=0
    # The enterprise firmware truncates authName/authPassword at 30 characters,
    # so a longer one registers with a silently different password and 401-loops.
    if [ "''${#pw}" -gt 30 ]; then
      echo "atftpd: phone line password is ''${#pw} characters; the 8851 truncates authPassword at 30." >&2
      echo "atftpd: the phone would register with a truncated password and fail authentication." >&2
      rc=1
    fi
    # <authPassword> is not escaped on its way into the XML, so these would make
    # the config file unparseable and the phone would reject it wholesale.
    case $pw in
      *'&'* | *'<'* | *'>'*)
        echo "atftpd: phone line password contains & < or >, which breaks the config XML." >&2
        rc=1
        ;;
    esac
    exit "$rc"
  '';

  pjsipSecrets = config.sops.templates."pjsip-secrets.conf".path;
  checkPjsipSecrets = pkgs.writeShellScript "asterisk-check-pjsip-secrets" ''
    # ';' starts a comment in asterisk's config parser, so a password containing
    # one is silently truncated at load and every authentication fails.
    if ${pkgs.gnugrep}/bin/grep -q '^password=.*;' ${lib.escapeShellArg pjsipSecrets}; then
      echo "asterisk: a password in ${pjsipSecrets} contains ';', which asterisk treats as" >&2
      echo "asterisk: the start of a comment -- it would be silently truncated at load." >&2
      exit 1
    fi
  '';
in
{
  systemd.services.asterisk.serviceConfig = {
    ExecStartPre = lib.mkBefore [
      (guard {
        unit = "asterisk";
        user = "asterisk";
        files = [ pjsipSecrets ];
      })
      checkPjsipSecrets
    ];
    Restart = "on-failure";
    RestartSec = "30s";
  };

  # atftpd drops to nobody itself, so that is the identity that has to be able
  # to read the phone's config file.
  systemd.services.atftpd.serviceConfig = {
    ExecStartPre = lib.mkBefore [
      (guard {
        unit = "atftpd";
        user = "nobody";
        files = [ phoneConfig ];
      })
      checkPhonePassword
    ];
    RestartSec = "30s";
  };
}
