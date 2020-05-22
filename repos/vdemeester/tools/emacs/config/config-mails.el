;;; config-mails.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Mails configuration
;;; Code:

;; ReadingEmail
(use-package simple
  :custom (read-mail-command #'gnus))
;; -ReadingEmail

;; AuthSource
(use-package auth-source
  :config
  (setq auth-sources '("~/.authinfo.gpg" "~/.authinfo"))
  (setq user-full-name "Vincent Demeester")
  (setq user-mail-address "vincent@sbr.pm"))
;; -AuthSource

;; EPA
(use-package epa-file
  :config
  (setq epa-file-cache-passphrase-for-symmetric-encryption t)
  :init
  (epa-file-enable))
;; -EPA

(setq gnus-init-file (expand-file-name "~/.config/gnus/init.el"))

;; SendmailCfg
(use-package smtpmail
  ;;:commands (mail-mode mail-text)
  :config
  (setq message-send-mail-function 'message-send-mail-with-sendmail)
  (setq sendmail-program "msmtp")
  (setq message-sendmail-f-is-evil 't)
  (setq message-sendmail-extra-arguments '("--read-envelope-from")))

(use-package sendmail
  ;;:commands (mail-mode mail-text)
  :defines (send-mail-function)
  :config
  (setq-default send-mail-function 'sendmail-send-it
                sendmail-program "/home/vincent/bin/msmtp"))
;; -SendmailCfg

;; MessageCfg
(use-package message
  :commands (message-mode message-cite-original-without-signature)
  :hook ((message-mode . my-message-hook))
  :config
  (setq mail-user-agent 'message-user-agent
        message-wide-reply-confirm-recipients t
        message-default-charset 'utf-8
        message-default-mail-headers "Cc: \nBcc: \n"
        message-kill-buffer-on-exit t
        message-generate-headers-first t)
  (add-to-list 'mm-body-charset-encoding-alist '(utf-8 . base64))

  (defun my-message-hook ()
    "Message mode hook."
    (turn-on-auto-fill)
    (set (make-local-variable 'company-backends)
         '(company-emoji company-capf company-files company-dabbrev))
    (company-mode 1)))
;; -MessageCfg

;; Notmuch
(if *sys/full*
    (progn
      (setenv "NOTMUCH_CONFIG" (expand-file-name ".config/notmuch/notmuchrc" (getenv "HOME")))
      (use-package notmuch
        :disabled
        :defer t
        :bind ("<f6>" . notmuch)
        :config
        (setq notmuch-search-oldest-first nil
              mail-user-agent 'message-user-agent
              notmuch-tree-show-out t)
        (setq notmuch-saved-searches
              '((:key "i" :name "inbox" :query "tag:Inbox")
                (:key "r" :name "redhat inbox folder" :query "folder:redhat/Inbox")
                (:key "p" :name "perso inbox folder" :query "folder:perso/Inbox")
                (:key "u" :name "unread" :query "tag:unread")
                (:key "F" :name "flagged" :query "tag:flagged")
                (:key "S" :name "sent" :query "tag:Sent Mail"))))))
;; -Notmuch

(provide 'config-mails)
;;; config-mails ends here
