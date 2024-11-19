;;; init.el --- My Simple Configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; https://github.com/jwiegley/use-package/issues/977#issuecomment-1100710726

;;; Code:

(eval-when-compile
  (require 'use-package))
(require 'bind-key)

(use-package emacs
  :bind (("C-h" . [backspace])
         ("M-h" . [C-backspace]))
  :custom
  (inhibit-startup-screen t)
  (tool-bar-mode nil)
  (menu-bar-mode nil)
  (scroll-step 1) ; Scroll line by line.
  (scroll-margin 15)
  (visible-bell t)
  (cursor-type 'bar)
  (bidi-inhibit-bpa t) ; faster with long lines
  (use-short-answers t) ; y or n instead of yes or no
  (indent-tabs-mode t)
  (standard-indent 8)
  (make-pointer-invisible nil) ; Don't hide the mouse pointer while typing.
  (delete-by-moving-to-trash t)
  (window-resize-pixelwise t)
  (frame-resize-pixelwise t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)

  ;; Built-in Modus themes
  (require-theme 'modus-theme)
  (modus-themes-variable-pitch-ui t)
  (modus-themes-mode-line '(accented borderless))
  ;; Quieter white spaces
  (modus-themes-operandi-color-overrides '((bg-whitespace . nil)))
  (custom-enabled-themes '(modus-operandi))
  :config
  (setq-default completion-ignore-case t) ; Non customize variable
  (set-face-attribute
   'default nil :font "mononoki"))

(use-package simple
  :custom
  (shell-command-prompt-show-cwd t)
  (async-shell-command-buffer 'new-buffer)
  (column-number-mode t)
  (indicate-unused-lines t)
  (kill-do-not-save-duplicates t)
  (kill-whole-line t))

(use-package files
  :custom
  (require-final-newline t)
  (make-backup-files nil) ; Don't create garbage *.~ file.
  (auto-save-default nil)) ; Also .#* files.

(use-package pixel-scroll
  :custom
  (pixel-scroll-precision-mode t))

(use-package adaptive-wrap
  :ensure t
  :hook (after-change-major-mode . adaptive-wrap-prefix-mode)
  :custom
  (adaptive-wrap-extra-indent 1))

(use-package window
  :custom
  (display-buffer-alist
   (let ((bottom 'display-buffer-in-side-window))
     `(("\\*Messages\\*" ,bottom)
       ("\\*Warnings\\*" ,bottom)
       ("\\*Help\\*" ,bottom)
       ("\\*Compile-Log\\*" ,bottom)
       ("\\*Shell Command Output\\*" ,bottom)
       ("\\*Eshell Command Output\\*" ,bottom)
       ("\\*Async Shell Command\\*" ,bottom)))))

(use-package minibuffer
  :custom
  (completion-styles '(flex)))

(use-package frame
  :custom
  (window-divider-mode t))

(use-package mouse
  :custom
  (context-menu-mode t)
  (mouse-drag-and-drop-region t))

(use-package delsel
  :custom
  (delete-selection-mode t))

(use-package desktop
  :custom
  (desktop-save-mode t)
  (desktop-save t))

;; Minibuffer history
(use-package savehist
  :custom
  (savehist-mode t))

(use-package fringe
  :custom
  (fringe-mode '(nil . 0))) ; Left only

(use-package comint
  :custom
  (comint-input-ignoredups t))

(use-package autorevert
  :custom
  (auto-revert-interval 1)
  (global-auto-revert-mode t))

(use-package tab-bar
  :custom
  (tab-bar-mode t)
  (tab-bar-show nil))

(use-package proced
  :hook (proced-mode . nix-prettify-mode)
  :custom
  (proced-auto-update-flag t)
  (proced-tree-flag t)
  (proced-enable-color-flag t)
  (proced-filter 'all))

(use-package daemons
  :ensure t)

(use-package paren
  :custom
  (show-paren-mode t)
  (show-paren-style 'expression)
  (show-paren-when-point-inside-paren t))

(use-package elec-pair
  :hook ((prog-mode conf-mode) . electric-pair-mode)
  :custom
  (electric-pair-inhibit-predicate
   (lambda (c)
     (or
      (nth 8 (syntax-ppss)) ; Not in string or comment
      (eq (char-syntax (following-char)) ?w) ;; Not next to a word.
      (electric-pair-default-inhibit c)))))

(use-package hl-line
  :custom
  (global-hl-line-mode t))

(use-package display-line-numbers
  :hook ((prog-mode conf-mode text-mode) . display-line-numbers-mode)
  :custom
  (display-line-numbers-width 3))

(use-package display-fill-column-indicator
  :hook ((prog-mode conf-mode text-mode) . display-fill-column-indicator-mode)
  :custom
  (fill-column 80))

;; TODO: Fix conflict with whitespace-mode
(use-package highlight-indent-guides
  :ensure t
  :hook ((prog-mode conf-mode text-mode) . highlight-indent-guides-mode))

(use-package subword
  :custom
  (global-superword-mode t))

(use-package newcomment
  :bind (([remap comment-dwim] . comment-line)))

(use-package whitespace
  :custom
  (whitespace-style '(face trailing tabs spaces space-mark tab-mark))
  (global-whitespace-mode t))

(use-package so-long
  :custom
  (global-so-long-mode t))

(use-package diff-hl
  :ensure t
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :custom
  (diff-hl-flydiff-mode t)
  (global-diff-hl-mode t))

(use-package repeat
  :custom
  (repeat-mode t))

(use-package ffap
  :config
  (ffap-bindings))

(use-package cape
  :ensure t)

(use-package corfu
  :ensure t
  :hook (minibuffer-setup
         . (lambda ()
             "Enable Corfu in the minibuffer if `completion-at-point' is bound."
             (when (where-is-internal #'completion-at-point
                                      (list (current-local-map)))
               (corfu-mode 1))))
  :bind (:map corfu-map
              ("<tab>" . corfu-next)
              ("TAB" . corfu-next)
              ([remap next-line] . nil) ; corfu-next
              ([remap previous-line] . nil)) ; corfu-previous
  ("M-h" . nil)
  :custom
  (global-corfu-mode t)
  (corfu-cycle t)
  (corfu-on-exact-match nil) ; Sometimes annoying
  (corfu-preselect-first nil)
  (corfu-auto-prefix 0)
  (corfu-auto-delay 0.)
  (corfu-auto t))

(use-package corfu-echo
  :hook (corfu-mode . corfu-echo-mode)
  :custom
  (corfu-echo-delay nil))

(use-package kind-icon
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package eldoc
  :custom
  (eldoc-echo-area-display-truncation-message nil)
  (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly))

(use-package mood-line
  :ensure t
  :custom
  (mood-line-mode t)
  (mood-line-show-indentation-style t)
  (mood-line-show-eol-style t)
  (mood-line-show-encoding-information t)
  :config
  (defun mood-line-segment-buffer-name () nil)) ; Show only in mode line

(use-package which-key
  :ensure t
  :custom
  (which-key-mode t))

;; Linkify uris.
(use-package goto-addr
  :custom
  (global-goto-address-mode t))

(use-package editorconfig
  :ensure t
  :custom
  (editorconfig-mode t)
  (editorconfig-trim-whitespaces-mode 'ignore))

(use-package dtrt-indent
  :ensure t
  :custom
  (dtrt-indent-global-mode t))

(use-package rainbow-delimiters
  :ensure t
  :hook ((prog-mode conf-mode) . rainbow-delimiters-mode))

(use-package project
  :hook (after-change-major-mode
         . (lambda ()
             (if-let ((proj (project-current nil)))
                 (setq-local default-directory (project-root proj))))))

(use-package breadcrumb
  :ensure t
  :config
  (breadcrumb-mode 1))

(use-package gud
  :hook gud-tooltip-mode)

(use-package dape
  :ensure t)

(use-package flymake-collection
  :ensure t
  :hook (after-init . flymake-collection-hook-setup))

(use-package eglot
  :hook (eglot-managed-mode
         . (lambda ()
             (add-hook 'flymake-diagnostic-functions 'eglot-flymake-backend)
             (setq indent-region-function 'eglot-format)))
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)
              ("C-c f" . eglot-format-buffer))
  :config
  (setq-default eglot-stay-out-of '(flymake-diagnostic-functions
                                    eldoc-documentation-strategy))
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nixd"))))

(use-package yasnippet
  :ensure t
  :custom
  (yas-global-mode t))

(use-package dired
  :hook (dired-mode . dired-hide-details-mode)
  :bind (:map dired-mode-map
              ([remap dired-mouse-find-file-other-window] . dired-find-file))
  :custom
  (dired-auto-revert-buffer t)
  (dired-recursive-deletes 'always) ;; Don't confirm.
  (dired-recursive-copies 'always)
  (dired-dwim-target t)
  (dired-find-subdir t)
  (dired-kill-when-opening-new-dired-buffer t))

(use-package dired-x)

(use-package dired-subtree
  :ensure t
  :bind (:map dired-mode-map
              ("TAB" . dired-subtree-toggle)))

(use-package diredfl
  :ensure t
  :custom
  (diredfl-global-mode t))

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode)
  :custom
  (all-the-icons-dired-monochrome nil))

(use-package direnv
  :ensure t
  :custom
  (direnv-mode t))

(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("?" . minibuffer-completion-help))
  :init
  (vertico-mode))

(use-package vertico-mouse
  :after vertico
  :hook (vertico-mode . vertico-mouse-mode))

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult
  :ensure t
  :bind (([remap switch-to-buffer] . consult-buffer)
         ([remap switch-to-other-buffer-window] . consult-buffer-other-window)
         ([remap switch-to-buffer-other-frame] . consult-buffer-other-frame)
         ([remap bookmark-jump] . consult-bookmark)
         ([remap project-switch-to-buffer] . consult-project-buffer)
         ([remap yank-pop] . consult-yank-pop)
         ([remap goto-line] . consult-goto-line)
         ("M-g f" . consult-flymake)
         ("M-g m" . consult-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi))
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package marginalia
  :ensure t
  :custom
  (marginalia-mode t))

(use-package all-the-icons-completion
  :ensure t
  :config
  (all-the-icons-completion-mode))

(use-package shell
  :bind (([remap shell] . new-shell))
  :config
  (defun new-shell ()
    (interactive)
    (shell (generate-new-buffer "*shell*"))))

(use-package bash-completion
  :ensure t
  :functions eshell-bol
  :config
  (bash-completion-setup)
  (defun bash-completion-from-eshell ()
    (interactive)
    (setq completion-at-point-functions '(bash-completion-eshell-capf)))
  (defun bash-completion-eshell-capf ()
    (bash-completion-dynamic-complete-nocomint
     (save-excursion (eshell-bol) (point))
     (point) t)))

(use-package mistty
  :ensure t)

(use-package eshell
  :hook (eshell-mode . bash-completion-from-eshell)
  :custom
  (eshell-hist-ignoredups t)
  (eshell-scroll-to-bottom-on-input t)
  (eshell-destroy-buffer-when-process-dies t)
  :config
  (defun eshell/v (&rest args)
    (apply 'eshell-exec-visual args)))

(use-package with-editor
  :ensure t
  :hook ((shell-mode . with-editor-export-editor)
         (eshell-mode . with-editor-export-editor)
         (term-exec . with-editor-export-editor)
         (vterm-mode . with-editor-export-editor))
  :custom
  (shell-command-with-editor-mode t))

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package forge
  :ensure t
  :after magit)

(use-package multi-mode
  :ensure t)

;; Programing languages

(use-package elisp-mode
  :hook (emacs-lisp-mode . flymake-mode)
  :config
  (add-hook 'emacs-lisp-mode-hook (lambda () (indent-tabs-mode -1))))

(use-package cc-mode
  :hook (c-mode . eglot-ensure))

(use-package python
  :hook (python-mode . eglot-ensure)
  :custom
  (python-flymake-command nil)
  :flymake-hook
  (python-mode flymake-collection-mypy
               flymake-collection-ruff))

(use-package lua-mode
  :ensure t)

(use-package sml-mode
  :ensure t)

(use-package scala-mode
  :ensure t)

(use-package rust-mode
  :ensure t
  :hook (rust-mode . eglot-ensure))

(use-package nix-mode
  :ensure t
  :hook (nix-mode . eglot-ensure)
  :custom
  (nix-indent-function #'nix-indent-line)
  (nix-repl-executable-args '("repl" "--show-trace")))

(use-package nix-ts-mode
  :ensure t
  :mode "\\.nix\\'")

(use-package haskell-mode
  :ensure t
  :hook (haskell-mode . eglot-ensure)
  :custom
  (haskell-indent-offset 2))

(use-package llvm-mode) ; Not in repositories

(use-package cmake-mode
  :ensure t
  :hook (cmake-mode . eglot-ensure))

(use-package yaml-mode
  :ensure t)

(use-package markdown-mode
  :ensure t
  :custom
  (markdown-header-scaling t))

(use-package auctex
  :ensure t
  :hook ((TeX-mode . eglot-ensure)
         (TeX-mode . prettify-symbols-mode))
  :custom
  (tex-engine 'luatex))

(use-package proof-general
  :ensure t
  :custom
  (proof-electric-terminator-enable t)
  (proof-output-tooltips t)
  (proof-three-window-mode-policy 'hybrid)
  (coq-one-command-per-line nil))

(use-package company-coq
  :ensure t
  :custom
  (company-coq-disabled-features '(pretty-math-symbols
                                   smart-subscripts
                                   snippets
                                   company))
  (company-coq-live-on-the-edge t)
  :config
  (add-to-list 'completion-at-point-functions
               (cape-company-to-capf #'company-coq-master-backend) t))

(provide 'init)

;;; init.el ends here

