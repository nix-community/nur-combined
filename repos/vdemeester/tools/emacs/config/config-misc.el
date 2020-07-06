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

(provide 'config-misc)
;;; config-misc.el ends here
