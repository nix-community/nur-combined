# Generated from an org file 💃
# See : https://sbr.pm/technical/configurations/mails.html
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.mails;
in
{

  options = {
    profiles.mails = {
      enable = mkEnableOption "Enable mails configuration";
      sync = mkEnableOption "Enable sync mail service";
      frequency = mkOption {
        default = "*:0/30";
        description = "Frequency at which the mail should be checked";
        type = types.str;
      };
    };
  };

  config =
    mkIf
      cfg.enable
      (
        mkMerge [
          {

            accounts.email = {
              maildirBasePath = "desktop/mails";
              accounts = {
                "redhat" = {
                  address = "vdemeest@redhat.com";
                  userName = "vdemeest@redhat.com";
                  realName = "Vincent Demeester";
                  passwordCommand = "${pkgs.gnupg}/bin/gpg -q --for-your-eyes-only --no-tty --exit-on-status-write-error --batch --passphrase-file ${config.home.homeDirectory}/sync/rh.pass -d ${config.home.homeDirectory}/desktop/documents/rh.pass.gpg";
                  imap.host = "imap.gmail.com";
                  smtp.host = "smtp.gmail.com";
                  mbsync = {
                    enable = true;
                    create = "both";
                    expunge = "both";
                    patterns = [ "*" "![Gmail]*" "[Gmail]/Sent Mail" "[Gmail]/Starred" "[Gmail]/All Mail" ];
                    extraConfig = {
                      channel = {
                        Sync = "All";
                      };
                      account = {
                        Timeout = 120;
                        PipelineDepth = 1;
                      };
                    };
                  };
                  notmuch.enable = cfg.sync;
                  astroid.enable = cfg.sync;
                  msmtp.enable = true;
                };
                "perso" = {
                  address = "vinc.demeester@gmail.com";
                  userName = "vinc.demeester@gmail.com";
                  realName = "Vincent Demeester";
                  passwordCommand = "${pkgs.gnupg}/bin/gpg -q --for-your-eyes-only --no-tty --exit-on-status-write-error --batch --passphrase-file ${config.home.homeDirectory}/sync/perso.pass -d ${config.home.homeDirectory}/desktop/documents/perso.pass.gpg";
                  imap.host = "imap.gmail.com";
                  smtp.host = "smtp.gmail.com";
                  mbsync = {
                    enable = true;
                    create = "both";
                    expunge = "both";
                    patterns = [ "*" "![Gmail]*" "[Gmail]/Sent Mail" "[Gmail]/Starred" "[Gmail]/All Mail" ];
                    extraConfig = {
                      channel = {
                        Sync = "All";
                      };
                      account = {
                        Timeout = 120;
                        PipelineDepth = 1;
                      };
                    };
                  };
                  notmuch.enable = cfg.sync;
                  astroid.enable = cfg.sync;
                  msmtp.enable = true;
                };
                "prv" = {
                  primary = true;
                  address = "vincent@demeester.fr";
                  userName = "vincent@demeester.fr";
                  realName = "Vincent Demeester";
                  passwordCommand = "${pkgs.gnupg}/bin/gpg -q --for-your-eyes-only --no-tty --exit-on-status-write-error --batch --passphrase-file ${config.home.homeDirectory}/sync/prv.pass -d ${config.home.homeDirectory}/desktop/documents/prv.pass.gpg";
                  imap.host = "mail.gandi.net";
                  smtp.host = "mail.gandi.net";
                  mbsync = {
                    enable = true;
                    create = "both";
                    expunge = "both";
                    patterns = [ "*" ];
                    extraConfig = {
                      channel = {
                        Sync = "All";
                      };
                      account = {
                        Timeout = 120;
                        PipelineDepth = 1;
                      };
                    };
                  };
                  notmuch.enable = cfg.sync;
                  astroid.enable = cfg.sync;
                  msmtp.enable = true;
                };
              };
            };

            home.file."bin/msmtp" = {
              text = ''
                #!${pkgs.stdenv.shell}
                ${pkgs.libnotify}/bin/notify-send "Sending mail ✉️"
                ${pkgs.msmtp}/bin/msmtp --read-envelope-from $@
              '';
              executable = true;
            };

            programs.msmtp.enable = true;

          }

          (
            mkIf cfg.sync {

              services.mbsync = {
                enable = true;
                preExec = "${config.xdg.configHome}/mbsync/preExec";
                postExec = "${config.xdg.configHome}/mbsync/postExec";
                frequency = cfg.frequency;
              };

              xdg.configFile."mbsync/preExec" = {
                text = ''
                  #!${pkgs.stdenv.shell}

                  export NOTMUCH_CONFIG=${config.xdg.configHome}/notmuch/notmuchrc
                  export NMBGIT=${config.xdg.dataHome}/notmuch/nmbug

                  ${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/desktop/mails/redhat ${config.home.homeDirectory}/desktop/mails/perso
                  ${pkgs.afew}/bin/afew -C  ${config.xdg.configHome}/notmuch/notmuchrc -m -v
                '';
                executable = true;
              };

              xdg.configFile."mbsync/postExec" = {
                text = ''
                  #!${pkgs.stdenv.shell}

                  export NOTMUCH_CONFIG=${config.xdg.configHome}/notmuch/notmuchrc
                  export NMBGIT=${config.xdg.dataHome}/notmuch/nmbug

                  ${pkgs.notmuch}/bin/notmuch new
                  ${pkgs.afew}/bin/afew -C ${config.xdg.configHome}/notmuch/notmuchrc --tag --new -v
                  # Remove inbox (lower-case)
                  ${pkgs.notmuch}/bin/notmuch tag -inbox -- tag:inbox
                  # Remove Inbox tagged message that are not in an Inbox
                  ${pkgs.notmuch}/bin/notmuch tag -Inbox -- not folder:redhat/Inbox and not folder:perso/Inbox and tag:Inbox
                  ${pkgs.libnotify}/bin/notify-send "Mails synced 📬"
                '';
                executable = true;
              };

              home.file."bin/msync" = {
                text = ''
                  #!${pkgs.stdenv.shell}
                  ${pkgs.libnotify}/bin/notify-send "Syncing mails 📫️"
                  systemctl --user start mbsync
                '';
                executable = true;
              };

              programs.mbsync.enable = true;
              programs.notmuch.enable = true;

              programs.afew = {
                enable = true;
                extraConfig = ''
                  [SpamFilter]
                  [KillThreadsFilter]
                  [ListMailsFilter]
                  [ArchiveSentMailsFilter]
                  [FolderNameFilter]
                  maildir_separator = /

                  [MailMover]
                  folders = perso/Inbox redhat/Inbox
                  rename = true

                  perso/Inbox = 'NOT tag:Inbox':"perso/[Gmail]/All Mail"
                  redhat/Inbox = 'NOT tag:Inbox':"redhat/[Gmail]/All Mail"
                '';
              };

              programs.astroid = {
                enable = true;
                externalEditor = "emacsclient -c";
                extraConfig = {
                  startup.queries.inbox = "tag:Inbox";
                  startup.queries.inbox_perso = "folder:perso/Inbox";
                  startup.queries.inbox_redhat = "folder:redhat/Inbox";
                };
              };

            }
          )

        ]
      );
}
