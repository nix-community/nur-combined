;;; config-misc.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Miscellaneous modes configuration
;;; Code:

;; UseHelpful
(use-package helpful
  :unless noninteractive
  :bind (("C-h f" . helpful-callable)
         ("C-h F" . helpful-function)
         ("C-h M" . helpful-macro)
         ("C-c h S" . helpful-at-point)
         ("C-h k" . helpful-key)
         ("C-h v" . helpful-variable)
         ("C-h C" . helpful-command)))
;; -UseHelpful

;; UseSSHConfig
(use-package ssh-config-mode
  :commands (ssh-config-mode
             ssh-authorized-keys-mode)
  :mode ((".ssh/config\\'"       . ssh-config-mode)
         ("sshd?_config\\'"      . ssh-config-mode)
         ("known_hosts\\'"       . ssh-known-hosts-mode)
         ("authorized_keys2?\\'" . ssh-authorized-keys-mode)))
;; -UseSSHConfig

(provide 'config-misc)
;;; config-misc.el ends here
