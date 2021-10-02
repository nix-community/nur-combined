# A module for configuring Emacs Notmuch to use the Home Manager email
# accounts.

{ config, lib, pkgs, ... }:

with lib;

let

  cfgNotmuch = config.programs.notmuch;

  cfgEmail = config.accounts.email;

  notmuchAccounts = filter (a: a.notmuch.enable) (attrValues cfgEmail.accounts);

  notmuchFccDir = account:
    let
      mkLine = address: ''
        ("${address}" . "\"${account.maildir.path}/${account.folders.sent}\"")
      '';
    in concatMapStrings mkLine ([ account.address ] ++ account.aliases);

  notmuchFccDirs = "'(${concatMapStrings notmuchFccDir notmuchAccounts})";

  # Enable prompting for sender if multiple accounts are defined.
  notmuchPromptFrom = if length notmuchAccounts > 1 then "'t" else "nil";

  elispFromAddress =
    ''(nth 1 (mail-extract-address-components (message-field-value "From")))'';

  # The host part of the `from` variable.
  elispFromHost = ''(nth 1 (split-string from "@"))'';

  messageSendHookFunction = ''
    (defun hm--message-send ()
      (make-local-variable 'message-user-fqdn)
      (let ((from ${elispFromAddress}))
        ;; Set the host part of the Message-ID to the email address host.
        (setq message-user-fqdn ${elispFromHost})))
  '';

  # Advice the notmuch-draft-save function to save if the correct
  # draft folder and with the correct FQDN in Message-ID.
  notmuchDraftSaveAdviceFunction = let
    mkAddressEntry = maildir: folders: address: ''
      ((string-equal from "${address}") "${maildir.path}/${folders.drafts}")
    '';

    mkAccountEntries = account:
      concatMapStrings (mkAddressEntry account.maildir account.folders)
      ([ account.address ] ++ account.aliases);
  in ''
    (defun hm--notmuch-draft-folder (from)
      (cond ${concatMapStrings mkAccountEntries notmuchAccounts}))
    (defun hm--notmuch-draft-save (orig-fun &rest args)
      (let* ((from ${elispFromAddress})
             (notmuch-draft-folder (hm--notmuch-draft-folder from))
             (message-user-fqdn ${elispFromHost}))
        (apply orig-fun args)))
  '';

in {
  meta.maintainers = [ maintainers.rycee ];

  config = mkIf (cfgEmail.accounts != { } && cfgNotmuch.enable) {
    programs.emacs.init.usePackage = {
      message = {
        enable = true;
        hook = [ "(message-send . hm--message-send)" ];
        config = ''
          ${messageSendHookFunction}

          (setq message-directory "${cfgEmail.maildirBasePath}")
        '';
        extraConfig = ''
          :functions message-field-value
        '';
      };

      notmuch = {
        config = ''
          ;; See https://github.com/Schnouki/dotfiles/blob/0d6716a041e1db95a27fc393baa8f38b850c5a25/emacs/init-50-mail.el#L243
          ${notmuchDraftSaveAdviceFunction}
          (advice-add 'notmuch-draft-save :around #'hm--notmuch-draft-save)

          (setq notmuch-fcc-dirs ${notmuchFccDirs}
                notmuch-always-prompt-for-sender ${notmuchPromptFrom})
        '';
      };
    };
  };
}
