;; -*- lexical-binding: t -*-
(add-to-list 'load-path (expand-file-name "lisp/" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lisp/modus-themes" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lisp/vorg" user-emacs-directory))
(require 'package)
;; load autoload files and populate load-path’s
(setq sbr-dumped-load-path load-path
      sbr-dumped t)
(package-initialize)
;; (package-initialize) doens’t require each package, we need to load
;; those we want manually
(dolist (package '(use-package company recentf moody helpful undo-tree cus-edit hardhat diff
                    use-package aggressive-indent savehist minions expand-region time uniquify isearch
                    minibuffer icomplete dired delsel direnv auth-source simple epa-file message
                    vc vc-dir vc-git modus-operandi-theme))
  (require package))
(load-theme 'modus-operandi t t)
;; dump image
(dump-emacs-portable (expand-file-name "emacs.pdmp" user-emacs-directory))
