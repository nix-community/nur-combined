{ pkgs, lib, ... }:

{
  mkMbsyncFetcher =
    {
      email,
      hostextra ? "",
      tls1dot ? 3,
      package ? pkgs.isync,
      configHead ? null,
      configHeadExtra ? "",
    }:
    let
      # emailuser = elemAt (splitString "@" email) 0;
      emailhost = lib.elemAt (lib.splitString "@" email) 1;
      name = emailhost;
      configHeadLet =
        if configHead == null then
          ''
            Host ${hostextra}${emailhost}
            User ${email}
            PassCmd "pass ${emailhost} | head -1"''
        else
          lib.removeSuffix "\n" configHead;
      configfile = pkgs.writeText "mbsync-config-${name}" ''
        IMAPAccount default
        ${configHeadLet}
        SSLType IMAPS
        SSLVersions TLSv1.${toString tls1dot}
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
    pkgs.writeShellScriptBin "mbsync-fetcher-${name}" ''
      # a small sanity check
      [[ ! -d "INBOX" ]] && exit 1
      exec ${package}/bin/mbsync --config=${configfile} --all "$@"
    '';
}
