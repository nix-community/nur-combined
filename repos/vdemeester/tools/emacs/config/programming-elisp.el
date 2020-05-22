;;; programming-elisp.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Emacs Lisp configurations
;;; Code:

(use-package company-elisp
  :after company
  :config
  (push 'company-elisp company-backends))

(provide 'programming-elisp)
;;; programming-elisp.el ends here
