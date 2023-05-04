# nix configs to reference:
# - <https://gitlab.com/simple-nixos-mailserver/nixos-mailserver>
# - <https://github.com/nix-community/nur-combined/-/tree/master/repos/eh5/machines/srv-m/mail-rspamd.nix>
#   - postfix / dovecot / rspamd / stalwart-jmap / sogo
#
# rspamd:
# - nixos: <https://nixos.wiki/wiki/Rspamd>
# - guide: <https://rspamd.com/doc/quickstart.html>
# - non-nixos example: <https://dataswamp.org/~solene/2021-07-13-smtpd-rspamd.html>
#
#
# my rough understanding of the pieces:
# - postfix handles SMTP protocol with the rest of the world.
# - dovecot implements IMAP protocol.
#   - client auth (i.e. validate that user@uninsane.org is who they claim)
#   - "folders" (INBOX, JUNK) are internal to dovecot?
#     or where do folders live, on-disk?
#
# - non-local clients (i.e. me) interact with BOTH postfix and dovecot, but primarily dovecot:
#   - mail reading is done via IMAP (so, dovecot)
#   - mail sending is done via SMTP/submission port (so, postfix)
#     - but postfix delegates authorization of that outgoing mail to dovecot, on the server side
#
# - local clients (i.e. sendmail) interact only with postfix

{ ... }:
{
  imports = [
    ./dovecot.nix
    ./postfix.nix
  ];


  #### SPAM FILTERING
  # services.rspamd.enable = true;
  # services.rspamd.postfix.enable = true;
}
