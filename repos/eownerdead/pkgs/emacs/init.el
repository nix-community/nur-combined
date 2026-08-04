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
  (fast-but-imprecise-scrolling t)
  (visible-bell t)
  (cursor-type 'bar)
  (bidi-inhibit-bpa t) ; faster with long lines
  (redisplay-skip-fontification-on-input t)
  (line-spacing 0.2)
  (use-short-answers t) ; y or n instead of yes or no
  (indent-tabs-mode t)
  (standard-indent 8)
  (tab-always-indent nil) ; Insert a tab character
  (make-pointer-invisible nil) ; Don't hide the mouse pointer while typing.
  (delete-by-moving-to-trash t)
  (window-resize-pixelwise t)
  (frame-resize-pixelwise t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)

  ;; Built-in Modus themes
  (require-theme 'modus-theme)
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t)
  (modus-themes-variable-pitch-ui t)
  (modus-themes-mode-line '(accented borderless))
  ;; Quieter white spaces
  (modus-themes-operandi-color-overrides '((bg-whitespace . nil)))
  (custom-enabled-themes '(modus-operandi))
  :config
  (defun setup-fonts (frame)
    (with-selected-frame frame
      (when (display-graphic-p frame)
        (set-face-attribute 'default nil :family "mononoki")
        (set-fontset-font nil 'japanese-jisx0208 "Noto Sans CJK JP"))))
  (add-hook 'after-make-frame-functions #'setup-fonts)
  (setq-default completion-ignore-case t)) ; Non customize variable

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
  (auto-save-default nil)
  (enable-local-variables :all)) ; Also .#* files.

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

(use-package frame
  :custom
  (window-divider-mode t))

(use-package mouse
  :custom
  (context-menu-mode t)
  (mouse-drag-and-drop-region t)
  (mouse-drag-and-drop-region-cross-program t))

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

(use-package vlf
  :ensure t
  :init
  (require 'vlf-setup))

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

(use-package smartparens
  :ensure t
  :hook (prog-mode conf-mode text-mode))

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

(use-package indent-bars
  :ensure t
  :hook ((prog-mode conf-mode text-mode) . indent-bars-mode)
  :custom
  (indent-bars-treesit-support t))

(use-package snap-indent
  :ensure t
  :hook ((prog-mode conf-mode text-mode) . snap-indent-mode))

(use-package aggressive-indent
  :ensure t)

(use-package treesit-fold
  :ensure t
  :custom
  (global-treesit-fold-mode t)
  :config
  (use-package treesit-fold-indicators
    :custom
    (global-treesit-fold-indicators-mode t)))

(use-package subword
  :custom
  (global-subword-mode t))

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
  :hook ((dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :custom
  (diff-hl-disable-on-remote t)
  (diff-hl-update-async t)
  (diff-hl-flydiff-mode t)
  (global-diff-hl-mode t))

(use-package repeat
  :custom
  (repeat-mode t))

(use-package ffap
  :config
  (ffap-bindings))

(use-package hotfuzz
  :ensure t
  :custom
  (completion-styles '(hotfuzz))
  (completion-category-defaults nil)
  (completion-category-overrides nil))

(use-package cape
  :ensure t
  :bind ("C-c p" . cape-prefix-map)
  :hook ((completion-at-point-function . cape-file)
         (completion-at-point-function . cape-dabbrev)))

(use-package corfu
  :ensure t
  :hook (minibuffer-setup
         . (lambda ()
             "Enable Corfu in the minibuffer if `completion-at-point' is bound."
             (when (where-is-internal #'completion-at-point
                                      (list (current-local-map)))
               (corfu-mode 1))))
  :bind (:map corfu-map
              ("M-RET" . corfu-insert)
              ([remap next-line] . nil) ; corfu-next
              ([remap previous-line] . nil)
              ("RET" . nil)) ; corfu-insert
  ("M-h" . nil)
  :custom
  (global-corfu-mode t)
  (corfu-cycle t)
  (corfu-on-exact-match 'insert) ; Sometimes annoying
  (corfu-preview-current 'insert)
  (corfu-preselect 'prompt) ; Don't
  (corfu-auto-prefix 0)
  (corfu-auto-delay 0.)
  (corfu-auto t)
  :config
  (use-package corfu-history
    :custom
    (corfu-history-mode t))

  (use-package corfu-indexed
    :custom
    (corfu-indexed-mode t)
    (corfu-indexed-start 1)
    :config
    ; https://github.com/minad/corfu/issues/223#issuecomment-2085418643
    (dotimes (i 10)
      (define-key corfu-mode-map
                  (kbd (format "M-%s" i))
                  (kbd (format "C-%s <tab>" i))))))

(use-package corfu-popupinfo
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay 0.))

(use-package kind-icon
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package eldoc
  :custom
  (eldoc-echo-area-display-truncation-message nil)
  (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly))

(use-package minions
  :ensure t
  :custom
  (minions-mode t))

(use-package which-key
  :custom
  (which-key-mode t))

;; Linkify uris.
(use-package goto-addr
  :custom
  (global-goto-address-mode t))

(use-package editorconfig
  :custom
  (editorconfig-mode t)
  (editorconfig-trim-whitespaces-mode 'ignore)
  :config
  (setq editorconfig-lisp-use-default-indent))

(use-package dtrt-indent
  :ensure t
  :custom
  (dtrt-indent-global-mode t))

(use-package rainbow-delimiters
  :ensure t
  :hook ((prog-mode conf-mode) . rainbow-delimiters-mode))

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

(use-package eglot-tempel
  :ensure t
  :custom
  (eglot-tempel-mode t))

(use-package eglot-supplements
  :config
  (use-package eglot-selran
    :bind (:map eglot-mode-map
                ("M-<up>" . eglot-selran-up)
                ("M-<down>" . eglot-selran-down)))
  (use-package eglot-cthier)
  (use-package eglot-marocc
    :bind (:map eglot-mode-map
                ("C-M-o" . eglot-marocc-request-highlights)
                ("C-M-n" . eglot-marocc-goto-next-highlight)
                ("C-M-p" . eglot-marocc-goto-previous-highlight)))
  (use-package eglot-semtok
    :hook (eglot-connect . eglot-semtok-on-connected)))

(use-package tramp
  :custom
  ; https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
  (tramp-use-scp-direct-remote-copying t)
  (tramp-copy-size-limit (* 1024 1024))
  :config
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))

  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process))

(use-package tramp-rpc)

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
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-mouse-drag-files t))

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

(use-package async
  :ensure t
  :custom
  (dired-async-mode t)
  (async-bytecomp-package-mode t))

(use-package direnv
  :ensure t
  :custom
  (direnv-mode t))

(use-package vertico
  :ensure t
  :bind (:map vertico-map
              ("?" . minibuffer-completion-help))
  :custom
  (vertico-mode t)
  (vertico-mouse-mode t))

(use-package vertico-directory
  :after vertico
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word)))

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

(use-package consult-eglot
  :ensure t)

(use-package consult-eglot-embark
  :ensure t
  :custom
  (consult-eglot-embark-mode t))

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
         ("M-g I" . consult-imenu-multi)
         ("M-s r" . consult-ripgrep))
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

(use-package helpful
  :ensure t
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key] . helpful-key)
         ([remap describe-command] . helpful-command)))

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

(use-package eat
  :ensure t
  :hook (eshell-load-hook . eat-eshell-mode)
  :bind (("C-x p s" . eat-project-other-window))
  :custom
  (eat-enable-auto-line-mode t))

(use-package ghostel
  :bind (:map project-prefix-map
              ("m" . ghostel-project)
              ("M" . ghostel-project-list-buffers))
  :custom
  (ghostel-tramp-shell-integration t)
  :config
  (add-to-list 'ghostel-tramp-shells '("rpc" login-shell)))

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

(use-package vc-jj
  :ensure t)

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status)
  :config
  (setq magit-commit-show-diff nil)
  (setq magit-refresh-status-buffer nil)
  (setq magit-tramp-pipe-stty-settings 'pty))

(use-package forge
  :ensure t
  :after magit)

(use-package majutsu
  :init
  (defalias 'completion-table-with-metadata 'org-completion-table-with-metadata))

(use-package casual
  :ensure t)

(use-package casual-bookmarks
  :bind (:map bookmark-bmenu-mode-map ("C-o" . casual-bookmarks-tmenu))
  :config
  (easy-menu-add-item global-map '(menu-bar)
                      casual-bookmarks-main-menu
                      "Tools"))

(use-package casual-calc
  :bind (:map calc-mode-map ("C-o" . casual-calc-tmenu)))

(use-package casual-calendar
  :bind (:map calendar-mode-map ("C-o" . casual-calendar)))

(use-package casual-compile
  :bind (:map compilation-mode-map ("C-o" . casual-compile-tmenu)
         :map grep-mode-map ("C-o" . casual-compile-tmenu)))

(use-package casual-dired
  :bind (:map dired-mode-map
              ("C-o" . casual-dired-tmenu)
              ("s" . casual-dired-sort-by-tmenu)
              ("/" . casual-dired-search-replace-tmenu)))

(use-package casual-editkit
  :bind (("C-o" . casual-editkit-main-tmenu)
         ("C-c w" . casual-editkit-windows-tmenu)
         ("C-c r" . casual-editkit-rectangle-tmenu)
         ("C-c g" . casual-editkit-registers-tmenu)
         ("C-c p" . casual-editkit-project-tmenu)))

(use-package casual-help
  :bind (:map help-mode-map ("C-o" . casual-help-tmenu)))

(use-package casual-ibuffer
  :bind (:map ibuffer-mode-map
              (("C-o" . casual-ibuffer-tmenu)
               ("F" . casual-ibuffer-filter-tmenu)
               ("s" . casual-ibuffer-sortby-tmenu))))

(use-package casual-image
  :bind (:map image-mode-map ("C-o" . casual-image-tmenu)))

(use-package casual-info
  :bind (:map Info-mode-map ("C-o" . casual-info-tmenu)))

(use-package casual-isearch
  :bind (:map isearch-mode-map ("C-o" . casual-isearch-tmenu)))

(use-package casual-make
  :bind (:map makefile-mode-map ("M-m" . casual-make-tmenu)))

(use-package casual-man
  :bind (:map Map-mode-map ("C-o" . casual-man-tmenu)))

(use-package casual-org
  :bind (:map org-mode-map ("M-m" . casual-org-tmenu)
         :map org-table-fedit-map ("M-m" . casual-org-table-fedit-tmenu)))

(use-package casual-agenda
  :bind (:map org-agenda-mode-map ("C-o" . casual-agenda-tmenu)))

(use-package polymode
  :ensure t
  :bind (("C-S-<return>" . polymode-eval-region-or-chunk)))

(use-package agent-shell)

(use-package ai-code
  :ensure t
  :custom
  (ai-code-backends-infra-terminal-backend 'ghostel)
  (ai-code-backends-infra-use-side-window nil))

;; Programing languages

(use-package elisp-mode
  :hook (emacs-lisp-mode . flymake-mode)
  :config
  (add-hook 'emacs-lisp-mode-hook (lambda () (indent-tabs-mode -1))))

(use-package c-ts-mode
  :hook (c-ts-mode . eglot-ensure)
  :custom
  (c-ts-mode-indent-offset 8)
  (c-ts-mode-indent-style 'k&r)
  :init
  (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode)))

(use-package python
  :hook (python-mode . eglot-ensure)
  :custom
  (python-flymake-command nil)
  :flymake-hook
  (python-mode flymake-collection-mypy
               flymake-collection-ruff))

(use-package lua-mode
  :ensure t)

(use-package ein
  :ensure t
  :custom
  (ein:markdown-enable-math t)
  (ein:worksheet-enable-undo t)
  (ein:output-area-inlined-images t)
  (ein:polymode t)
  :init
  ; https://github.com/millejoh/emacs-ipython-notebook/pull/925
  (defalias 'pm--visible-buffer-name 'pm--buffer-name))

(use-package sml-mode
  :ensure t)

(use-package scala-ts-mode
  :ensure t)

(use-package rust-mode
  :ensure t
  :hook (rust-mode . eglot-ensure)
  :custom
  (rust-mode-treesitter-derive t))

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
  :ensure t)

(use-package haskell-ts-mode
  :ensure t
  :hook (haskell-ts-mode . eglot-ensure)
  :custom
  (haskell-indent-offset 2)
  :init
  (add-to-list 'major-mode-remap-alist '(haskell-mode . haskell-ts-mode)))

(use-package agda2-mode
  :ensure t)

(use-package llvm-mode) ; Not in repositories

(use-package cmake-ts-mode
  :hook (cmake-mode . eglot-ensure))

(use-package org-mode
  :custom
  (org-directory "~/persist/documents/org")
  :config
  (add-to-list 'org-modules 'mouse))

(use-package org-modern
  :ensure t
  :custom
  (global-org-modern-mode t))

(use-package markdown-mode
  :ensure t
  :custom
  (markdown-header-scaling t))

(use-package poly-markdown
  :ensure t
  :bind (("C-S-<return>" . polymode-eval-region-or-chunk)))

(use-package auctex
  :ensure t
  :hook ((TeX-mode . eglot-ensure)
         (TeX-mode . prettify-symbols-mode))
  :custom
  (tex-engine 'luatex))

(use-package auctex-latexmk
  :ensure t
  :config
  (auctex-latexmk-setup))

(use-package typst-ts-mode
  :ensure t
  :config
  (add-to-list 'eglot-server-programs '(typst-ts-mode "tinymist")))

(provide 'init)

;;; init.el ends here

