;;; config-appearance.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Appearance configuration
;;; Code:
;; TypeFaceConfiguration
(use-package emacs
  :defer 3
  :bind ("C-c f r" . mu-reset-fonts)
  :commands (mu-reset-fonts)
  :hook (after-init . mu-reset-fonts)
  :config

  (defun mu-reset-fonts ()
    "Reset fonts to my preferences."
    (interactive)
    (when (member "Ubuntu Mono" (font-family-list))
      (set-face-attribute 'default nil
                          :family "Ubuntu Mono"
                          :height font-height)
      (set-face-attribute 'fixed-pitch nil
                          :family "Ubuntu Mono"
                          :height font-height))
    (when (member "Ubuntu Sans" (font-family-list))
      (set-face-attribute 'variable-pitch nil
                          :family "Ubuntu Sans"
                          :height font-height
                          :weight 'regular))))
;; -TypeFaceConfiguration

(use-package emacs
  :config
  (setq-default use-file-dialog nil
                use-dialog-box nil
                echo-keystrokes 0.1
                line-number-display-limit-width 10000
                indicate-buffer-boundaries 'left
                indicate-empty-lines +1
                display-time-world-list '(("Europe/London" "London")
                                          ("Europe/Paris" "Paris")
                                          ("America/New_York" "Boston")
                                          ("America/Los_Angeles" "San-Francisco")
                                          ("Asia/Calcutta" "Bangalore")
                                          ("Australia/Brisbane" "Brisbane")))
  (line-number-mode 1)
  (column-number-mode 1)
  (global-hl-line-mode 1)
  (global-unset-key (kbd "C-z"))
  (global-unset-key (kbd "C-x C-z"))
  (global-unset-key (kbd "C-h h")))

;; LoadTheme
;; -LoadTheme

;; UseTheme
(use-package emacs
  :config
  (setq custom-safe-themes t)

  (defun sbr/before-load-theme (&rest args)
    "Clear existing theme settings instead of layering them.
Ignores `ARGS'."
    (mapc #'disable-theme custom-enabled-themes))

  (advice-add 'load-theme :before #'sbr/before-load-theme)

  (defvar contrib/after-load-theme-hook nil
    "Hook run after a color theme is loaded using `load-theme'.")

  (defun contrib/run-after-load-theme-hook (&rest _)
    "Run `contrib/after-load-theme-hook'."
    (run-hooks 'contrib/after-load-theme-hook))

  (advice-add #'load-theme :after #'contrib/run-after-load-theme-hook)

  (defcustom sbr/modus-themes-toggle-hook nil
    "Hook that runs after `prot/modus-themes-toggle' is invoked."
    :type 'hook)

  (defun sbr/modus-themes-toggle ()
    "Toggle between `sbr/modus-operandi' and `sbr/modus-vivendi'.
Also run `sbr/modus-themes-toggle-hook'."
    (interactive)
    (if (eq (car custom-enabled-themes) 'modus-operandi)
        (sbr/modus-vivendi)
      (sbr/modus-operandi))
    (run-hooks 'sbr/modus-themes-toggle-hook))

  :bind ("<f10>" . sbr/modus-themes-toggle)
  :hook ((after-init-hook . sbr/modus-operandi)))

(use-package modus-operandi-theme
  :config
  (defun sbr/modus-operandi ()
    "Enable some Modus Operandi variables and load the theme.
This is used internally by `sbr/modus-themes-toggle'."
    (setq modus-operandi-theme-slanted-constructs t
          modus-operandi-theme-bold-constructs t
          modus-operandi-theme-visible-fringes nil
          modus-operandi-theme-3d-modeline t
          modus-operandi-theme-subtle-diffs t
          modus-operandi-theme-distinct-org-blocks nil
          modus-operandi-theme-proportional-fonts nil
          modus-operandi-theme-rainbow-headings t
          modus-operandi-theme-section-headings nil
          modus-operandi-theme-scale-headings nil
          modus-operandi-theme-scale-1 1.05
          modus-operandi-theme-scale-2 1.1
          modus-operandi-theme-scale-3 1.15
          modus-operandi-theme-scale-4 1.2)
    (load-theme 'modus-operandi t))
  (defun sbr/modus-operandi-custom ()
    "Customize modus-operandi theme"
    (message "fooo")
    (if (member 'modus-operandi custom-enabled-themes)
        (modus-operandi-theme-with-color-variables ; this macro allows us to access the colour palette
         (custom-theme-set-faces
          'modus-operandi
          `(whitespace-tab ((,class (:background "#ffffff" :foreground "#cccccc"))))
          `(whitespace-space ((,class (:background "#ffffff" :foreground "#cccccc"))))
          `(whitespace-hspace ((,class (:background "#ffffff" :foreground "#cccccc"))))
          `(whitespace-newline ((,class (:background "#ffffff" :foreground "#cccccc"))))
          `(whitespace-indentation ((,class (:background "#ffffff" :foreground "#cccccc"))))
          ))))
  (add-hook 'contrib/after-load-theme-hook 'sbr/modus-operandi-custom)
  (sbr/modus-operandi))

(use-package modus-vivendi-theme
  :config
  (defun sbr/modus-vivendi ()
    "Enable some Modus Vivendi variables and load the theme.
This is used internally by `sbr/modus-themes-toggle'."
    (setq modus-vivendi-theme-slanted-constructs t
          modus-vivendi-theme-bold-constructs t
          modus-vivendi-theme-visible-fringes nil
          modus-vivendi-theme-3d-modeline t
          modus-vivendi-theme-subtle-diffs t
          modus-vivendi-theme-distinct-org-blocks nil
          modus-vivendi-theme-proportional-fonts nil
          modus-vivendi-theme-rainbow-headings nil
          modus-vivendi-theme-section-headings nil
          modus-vivendi-theme-scale-headings nil
          modus-vivendi-theme-scale-1 1.05
          modus-vivendi-theme-scale-2 1.1
          modus-vivendi-theme-scale-3 1.15
          modus-vivendi-theme-scale-4 1.2)
    (load-theme 'modus-vivendi t))
  (defun sbr/modus-vivendi-custom ()
    "Customize modus-vivendi theme"
    (if (member 'modus-vivendi custom-enabled-themes)
        (modus-vivendi-theme-with-color-variables ; this macro allows us to access the colour palette
         (custom-theme-set-faces
          'modus-vivendi
          `(whitespace-tab ((,class (:background "#000000" :foreground "#666666"))))
          `(whitespace-space ((,class (:background "#000000" :foreground "#666666"))))
          `(whitespace-hspace ((,class (:background "#000000" :foreground "#666666"))))
          `(whitespace-newline ((,class (:background "#000000" :foreground "#666666"))))
          `(whitespace-indentation ((,class (:background "#000000" :foreground "#666666"))))
          ))))
  (add-hook 'contrib/after-load-theme-hook 'sbr/modus-vivendi-custom))
;; -UseTheme

(use-package emacs
  :config
  (setq window-divider-default-right-width 1)
  (setq window-divider-default-bottom-width 1)
  (setq window-divider-default-places 'right-only)
  :hook (after-init-hook . window-divider-mode))

;; UseMoody
(use-package moody
  :config
  (setq-default x-underline-at-descent-line t
                ;; Show buffer position percentage starting from top
                mode-line-percent-position '(-3 "%o"))

  (setq-default mode-line-format
                '("%e"
                  mode-line-front-space
                  mode-line-client
                  mode-line-modified
                  mode-line-remote
                  mode-line-frame-identification
                  mode-line-buffer-identification " " mode-line-position
                  (vc-mode vc-mode)
                  (multiple-cursors-mode mc/mode-line)
                  " " mode-line-modes
                  mode-line-end-spaces))

  (use-package minions
    :ensure t
    :config
    (setq-default minions-mode-line-lighter "λ="
                  minions-mode-line-delimiters '("" . "")
                  minions-direct '(flycheck-mode))
    (minions-mode +1))

  (use-package time
    :config
    (setq-default display-time-24hr-format t
                  display-time-day-and-date t
                  display-time-world-list '(("Europe/Paris" "Paris")
                                            ("Europe/London" "London")
                                            ("America/New_York" "Boston")
                                            ("America/Los_Angeles" "San Francisco")
                                            ("Asia/Calcutta" "Bangalore")
                                            ("Australia/Brisbane" "Brisbane"))
                  display-time-string-forms
                  '((format "%s %s %s, %s:%s"
                            dayname
                            monthname day
                            24-hours minutes)))
    (display-time))

  (setq-default global-mode-string (remove 'display-time-string global-mode-string)
                mode-line-end-spaces
                (list (propertize " " 'display '(space :align-to (- right 19)))
                      'display-time-string))

  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))
;; -UseMoody

(provide 'config-appearance)
;;; config-appearance.el ends here
