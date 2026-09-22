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
    rc=0
    # One <authPassword> per line button, so read them all rather than assuming
    # a single match -- with several, $(...) would return them concatenated and
    # the length check below would be measuring the wrong thing.
    #
    # The enterprise firmware truncates authName/authPassword at 30 characters,
    # so a longer one registers with a silently different password and 401-loops.
    while IFS= read -r pw; do
      if [ "''${#pw}" -gt 30 ]; then
        echo "atftpd: a phone line password is ''${#pw} characters; the 8851 truncates authPassword at 30." >&2
        echo "atftpd: the phone would register with a truncated password and fail authentication." >&2
        rc=1
        break
      fi
    done < <(${pkgs.gnused}/bin/sed -n 's:.*<authPassword>\(.*\)</authPassword>.*:\1:p' ${lib.escapeShellArg phoneConfig})
    # No password is escaped on its way into the XML, so these would make the
    # config file unparseable and the phone would reject it wholesale.
    while IFS= read -r v; do
      case $v in
        *'&'* | *'<'* | *'>'*)
          echo "atftpd: a password in the phone config contains & < or >, which breaks the XML." >&2
          rc=1
          break
          ;;
      esac
    done < <(${pkgs.gnused}/bin/sed -n \
      -e 's:.*<authPassword>\(.*\)</authPassword>.*:\1:p' \
      -e 's:.*<sshPassword>\(.*\)</sshPassword>.*:\1:p' ${lib.escapeShellArg phoneConfig})
    exit "$rc"
  '';

  pjsipSecrets = config.sops.templates."pjsip-secrets.conf".path;
  sipSecrets = config.sops.templates."sip-secrets.conf".path;
  checkPjsipSecrets = pkgs.writeShellScript "asterisk-check-pjsip-secrets" ''
    # ';' starts a comment in asterisk's config parser, so a password containing
    # one is silently truncated at load and every authentication fails.
    if ${pkgs.gnugrep}/bin/grep -qE '^(password|secret)=.*;' ${lib.escapeShellArg pjsipSecrets} ${lib.escapeShellArg sipSecrets}; then
      echo "asterisk: a password contains ';', which asterisk treats as" >&2
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
        files = [
          pjsipSecrets
          sipSecrets
        ];
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
