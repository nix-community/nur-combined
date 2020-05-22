;;; config-editing.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Editing configuration
;;; Code:
(setq-default enable-remote-dir-locals t)

;; UseSmartParens
(use-package smartparens
  :commands (smartparens-mode smartparens-global-mode show-smartparens-global-mode
                              sp-split-sexp sp-newline sp-up-sexp)
  :hook ((prog-mode . turn-on-smartparens-mode)
         (markdown-mode . turn-on-smartparens-mode)
         (org-mode . turn-on-smartparens-mode)
         (prog-mode . turn-on-show-smartparens-mode)
         (markdown-mode . turn-on-show-smartparens-mode)
         (org-mode . turn-on-show-smartparens-mode)
         (emacs-lisp-mode . turn-on-smartparens-strict-mode))
  :config
  (require 'smartparens-config)

  (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil)
  (sp-local-pair 'web-mode "{%" "%}")
  (sp-with-modes '(org-mode)
    (sp-local-pair "=" "="))
  (sp-with-modes 'emacs-lisp-mode
    ;; disable ', it's the quote character!
    (sp-local-pair "'" nil :actions nil)
    ;; also only use the pseudo-quote inside strings where it
    ;; serves as hyperlink.
    (sp-local-pair "`" "'" :when '(sp-in-string-p sp-in-comment-p))))
;; -UseSmartParens

;; UseAggressiveIndent
(use-package aggressive-indent
  :bind ("C-c e i" . aggressive-indent-mode)
  :hook ((lisp-mode       . aggressive-indent-mode)
         (emacs-lisp-mode . aggressive-indent-mode))
  :config
  ;; Free C-c C-q, used in Org and in CIDER
  (unbind-key "C-c C-q" aggressive-indent-mode-map))
;; -UseAggressiveIndent

;; UseUndoTree
(use-package undo-tree
  :hook (after-init . global-undo-tree-mode)
  :config
  (setq-default undo-tree-visualizer-timestamps t
                undo-tree-enable-undo-in-region t))
;; -UseUndoTree

;; UseWhitespace
(use-package whitespace
  :commands (whitespace-mode sbr/toggle-invisibles)
  :config
  (setq-default whitespace-style '(face tabs spaces trailing space-before-tab newline indentation empty space-after-tab space-mark tab-mark newline-mark))
  (defun sbr/toggle-invisibles ()
    "Toggles the display of indentation and space characters."
    (interactive)
    (if (bound-and-true-p whitespace-mode)
        (whitespace-mode -1)
      (whitespace-mode)))
  :bind ("<f6>" . sbr/toggle-invisibles))
;; -UseWhitespace

;; UseExpandRegion
(use-package expand-region
  :commands (er/expand-region er/contract-region)
  :bind (("C-=" . er/expand-region)
         ("C--". er/contract-region)))
;; -UseExpandRegiston

(use-package iedit
  :disabled
  :defines hydra-iedit/body
  :bind* (:map global-map
               ("C-*" . iedit-mode)
               :map iedit-mode-keymap
               ("M-n" . iedit-next-occurence)
               ("M-p" . iedit-prev-occurence))
  :config
  (defhydra hydra-iedit (:color pink :columns 1)
    "IEDIT"
    ("C-*" iedit-mode "toggle")
    ("C-p" iedit-prev-occurrence "prev")
    ("C-n" iedit-next-occurrence "next")
    ("C-g" iedit-quit "toggle" :color blue)))

;; UseVisualRegexp
(use-package visual-regexp
  :commands (vr/replace vr/query-replace vr/mc-mark)
  :bind (("C-c r"   . vr/replace)
         ("C-c %"   . vr/query-replace)
         ("C-c m" . vr/mc-mark)))
;; -UseVisualRegexp

;; UseHideShow
(use-package hs-minor-mode
  :hook ((prog-mode . hs-minor-mode)))
;; -UseHideShow

(use-package easy-kill
  :commands (easy-kill)
  :config
  (global-set-key [remap kill-ring-save] 'easy-kill)
  (global-set-key [remap mark-sexp] 'easy-mark))

(use-package display-line-numbers
  :hook (prog-mode . display-line-numbers-mode)
  :config
  (setq-default display-line-numbers-type 'relative)
  (defun sbr/toggle-line-numbers ()
    "Toggles the display of line numbers.  Applies to all buffers."
    (interactive)
    (if (bound-and-true-p display-line-numbers-mode)
        (display-line-numbers-mode -1)
      (display-line-numbers-mode)))
  :bind ("<f7>" . sbr/toggle-line-numbers))

(add-hook 'prog-mode-hook 'toggle-truncate-lines)

(use-package newcomment
  :config
  (setq-default comment-empty-lines t
                comment-fill-column nil
                comment-multi-line t
                comment-style 'multi-line)
  (defun prot/comment-dwim (&optional arg)
    "Alternative to `comment-dwim': offers a simple wrapper
around `comment-line' and `comment-dwim'.

If the region is active, then toggle the comment status of the
region or, if the major mode defines as much, of all the lines
implied by the region boundaries.

Else toggle the comment status of the line at point."
    (interactive "*P")
    (if (use-region-p)
        (comment-dwim arg)
      (save-excursion
        (comment-line arg))))

  :bind (("C-;" . prot/comment-dwim)
         ("C-:" . comment-kill)
         ("M-;" . comment-indent)
         ("C-x C-;" . comment-box)))

;; UseFlySpell
(use-package flyspell
  :commands (flyspell-prog-mode flyspell-mode)
  :hook((text-mode . turn-on-flyspell)
        (prog-mode . turn-on-flyspell))
  :config
  (define-key flyspell-mode-map (kbd "C-;") nil)
  (setq-default flyspell-issue-message-flag nil
                flyspell-issue-welcome-flag nil
                ispell-program-name "hunspell"
                ispell-local-dictionary "en_GB"
                ispell-local-dictionary-alist
                '(("en_GB"
                   "[[:alpha:]]"
                   "[^[:alpha:]]"
                   "[']"
                   nil
                   ("-d" "en_GB,fr_FR")
                   nil
                   utf-8))))
;; -UseFlySpell

(use-package emacs
  :init
  (setq-default tab-always-indent 'complete
                tab-width 4
                indent-tabs-mode nil))

(use-package emacs
  :hook (before-save . delete-trailing-whitespace))

(use-package delsel
  :config
  (delete-selection-mode 1))

(use-package emacs
  :custom
  (repeat-on-final-keystroke t)
  (set-mark-command-repeat-pop t)
  :bind ("M-z" . zap-up-to-char))

(use-package emacs
  :config
  (defun prot/new-line-below ()
    "Create a new line below the current one.  Move the point to
the absolute beginning.  Also see `prot/new-line-above'."
    (interactive)
    (end-of-line)
    (newline))

  (defun prot/new-line-above ()
    "Create a new line above the current one.  Move the point to
the absolute beginning.  Also see `prot/new-line-below'."
    (interactive)
    (beginning-of-line)
    (newline)
    (forward-line -1))

  (defun prot/yank-replace-line-or-region ()
    "Replace the line at point with the contents of the last
stretch of killed text.  If the region is active, operate over it
instead.  This command can then be followed by the standard
`yank-pop' (default is bound to M-y)."
    (interactive)
    (if (use-region-p)
        (progn
          (delete-region (region-beginning) (region-end))
          (yank))
      (progn
        (delete-region (point-at-bol) (point-at-eol))
        (yank))))

  :bind (("C-S-SPC" . contrib/mark-whole-word)
         ("<C-return>" . prot/new-line-below)
         ("<C-S-return>" . prot/new-line-above)
         ("M-SPC" . cycle-spacing)
         ("M-o" . delete-blank-lines)
         ("<C-f6>" . tear-off-window)
         ("C-S-y" . prot/yank-replace-line-or-region)))

(use-package crux
  :disabled
  :commands (crux-transpose-windows
             crux-duplicate-current-line-or-region
             crux-rename-file-and-buffer
             crux-open-with)
  :bind (("C-c w S" . crux-transpose-windows)
         ("C-c d" . crux-duplicate-current-line-or-region)
         ("<C-f2>" . crux-rename-file-and-buffer)
         :map dired-mode-map
         ("<M-return>" . crux-open-with)))

(use-package goto-last-change
  :disabled
  :commands goto-last-change
  :bind ("C-z" . goto-last-change))

(use-package pdf-tools
  :mode  ("\\.pdf\\'" . pdf-view-mode)
  :config
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations t)
  (setq pdf-view-midnight-colors '("#ffffff" . "#000000"))
  (pdf-tools-install :no-query)
  (require 'pdf-occur))

(use-package paste-sbr
  :commands (htmlize-paste-it)
  :bind ("C-c e p" . htmlize-paste-it))

(provide 'config-editing)
;;; config-editing.el ends here
