{
  pkgs,
  lib ? pkgs.lib,
  ...
}:

{
  mkMbsyncFetcher =
    {
      email,
      host ? lib.elemAt (lib.splitString "@" email) 1,
      passcmd ? "pass ${host} | head -1",
      tls1dot ? 3,
      package ? pkgs.isync,
      configHeadExtra ? "",
    }:
    let
      configfile = pkgs.writeText "mbsync-config-${host}" ''
        IMAPAccount default
        SSLType IMAPS
        SSLVersions TLSv1.${toString tls1dot}
        Host ${host}
        User ${email}
        PassCmd "${passcmd}"
        ${configHeadExtra}

        IMAPStore default-remote
        Account default

        MaildirStore default-local
        Subfolders Verbatim
        # The trailing "/" is important
        Path ./
        Inbox ./INBOX

        Channel default
        Far :default-remote:
        Near :default-local:
        Patterns *
        Create Both
        Expunge Both
        SyncState *
      '';
    in
    pkgs.writeShellScriptBin "mbsync-fetcher-${host}" ''
      # a small sanity check
      [[ ! -d "INBOX" ]] && exit 1
      exec ${package}/bin/mbsync --config=${configfile} --all "$@"
    '';
}
