;; -*- lexical-binding: t; -*
;; Configure use-package to use system (nix) packages
;; inspired from https://www.srid.ca/vanilla-emacs-nixos.html
(require 'package)
(setq package-archives nil)
;;(package-initialize)
(require 'use-package)

(require 'org)
(let* ((file (expand-file-name "emacs.org" user-emacs-directory))
       (base-name (file-name-sans-extension file))
       (exported-file (concat base-name ".el")))
  (org-babel-tangle-file file exported-file "emacs-lisp")
  (load-file exported-file))
;(org-babel-load-file (expand-file-name "emacs.org"))
