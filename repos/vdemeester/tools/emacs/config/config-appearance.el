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
  (setq-default custom-safe-themes t)
  (setq-default custom--inhibit-theme-enable nil)

  (defun sbr/before-load-theme (&rest args)
    "Clear existing theme settings instead of layering them.
Ignores `ARGS'."
    (mapc #'disable-theme custom-enabled-themes))

  (advice-add 'load-theme :before #'sbr/before-load-theme))
;; -UseTheme

;; UseWindowDivider
(use-package emacs
  :config
  (setq window-divider-default-right-width 1)
  (setq window-divider-default-bottom-width 1)
  (setq window-divider-default-places 'right-only)
  :hook (after-init-hook . window-divider-mode))
;; -UseWindowDivider

;; UseTabbar
(use-package tab-bar
  :config
  (setq-default tab-bar-close-button-show nil)
  (setq-default tab-bar-close-last-tab-choice 'tab-bar-mode-disable)
  (setq-default tab-bar-close-tab-select 'recent)
  (setq-default tab-bar-new-tab-choice t)
  (setq-default tab-bar-new-tab-to 'right)
  (setq-default tab-bar-position nil)
  (setq-default tab-bar-show t)
  (setq-default tab-bar-tab-hints nil)
  (setq-default tab-bar-tab-name-function 'tab-bar-tab-name-all)

  (defun sbr/icomplete-tab-bar-tab-dwim ()
    "Do-What-I-Mean function for getting to a `tab-bar-mode' tab.
If no other tab exists, create one and switch to it.  If there is
one other tab (so two in total) switch to it without further
questions.  Else use completion to select the tab to switch to."
    (interactive)
    (let ((tabs (mapcar (lambda (tab)
                          (alist-get 'name tab))
                        (tab-bar--tabs-recent))))
      (cond ((eq tabs nil)
             (tab-new))
            ((eq (length tabs) 1)
             (tab-next))
            (t
             (tab-bar-switch-to-tab
              (completing-read "Select tab: " tabs nil t))))))

  :bind (("C-x t t" . sbr/icomplete-tab-bar-tab-dwim)
         ("C-x t s" . tab-switcher)))
;; -UseTabbar

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
