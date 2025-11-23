{
  pkgs,
  lib ? pkgs.lib,
}:

{
  mkMbsyncFetcher =
    {
      email,
      # This parameter is needed since isync 1.5.0 because:
      #   https://sourceforge.net/p/isync/isync/ci/v1.5.1/tree/NEWS
      #   - The reference point for relative local paths in the configuration file
      #     is now the file's containing directory
      maildirpath,
      host ? lib.elemAt (lib.splitString "@" email) 1,
      passcmd ? "pass ${host} | head -1",
      package ? pkgs.isync,
      configHeadExtra ? "",
    }:
    pkgs.writeShellApplication {
      name = "mbsync-fetcher-${host}";
      runtimeInputs = [ package ];
      runtimeEnv.CONFIG_FILE = pkgs.writeText "mbsync-config-${host}" ''
        IMAPAccount default
        TLSType IMAPS
        TLSVersions -1.2
        Host ${host}
        User ${email}
        PassCmd "${passcmd}"
        ${configHeadExtra}

        IMAPStore default-remote
        Account default

        MaildirStore default-local
        Subfolders Verbatim
        # The trailing "/" is important
        Path ${maildirpath}/
        Inbox ${maildirpath}/INBOX

        Channel default
        Far :default-remote:
        Near :default-local:
        Patterns *
        Create Both
        Expunge Both
        SyncState *
      '';
      text = ''
        # a small sanity check
        [[ ! -d "INBOX" ]] && exit 1
        exec mbsync --config="$CONFIG_FILE" --all "$@"
      '';
    };

  mkMsmtpAccount =
    name: configtxt:
    pkgs.writeShellApplication {
      name = "msmtp-${name}";
      runtimeInputs = [ pkgs.msmtp ];
      runtimeEnv.CONFIG_FILE = pkgs.writeText "msmtp-config-file-${name}" ''
        # -*- mode:conf-space; -*-
        account default
        auth on
        tls on
        tls_starttls off
        ${configtxt}
        syslog
      '';
      text = ''
        exec msmtp --file="$CONFIG_FILE" "$@"
      '';
    };
}
