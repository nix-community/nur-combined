;;; early-init.el --- -*- lexical-binding: t -*-
;; PkgStartup
(setq package-enable-at-startup nil)
;; -PkgStartup

;; FrameResize
(setq frame-inhibit-implied-resize t)
;; -FrameResize

;; DisableUI
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(horizontal-scroll-bar-mode -1)
(message "foo")
(message "bar")
;; -DisableUI

;; GarbageCollection
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)
;; -GarbageCollection

;; FileNameHandler
(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
;; -FileNameHandler

;; EarlyThemeSetup
(defvar contrib/after-load-theme-hook nil
  "Hook run after a color theme is loaded using `load-theme'.")

(defun contrib/run-after-load-theme-hook (&rest _)
  "Run `contrib/after-load-theme-hook'."
  (run-hooks 'contrib/after-load-theme-hook))

(advice-add #'load-theme :after #'contrib/run-after-load-theme-hook)

(add-to-list 'load-path (concat user-emacs-directory "lisp/modus-themes"))
(require 'modus-operandi-theme)

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
(sbr/modus-operandi)
;; -EarlyThemeSetup

;;-EarlyFontSetup
(defconst font-height 130
  "Default font-height to use.")
;; Middle/Near East: שלום, السّلام عليكم
(when (member "Noto Sans Arabic" (font-family-list))
  (set-fontset-font t 'arabic "Noto Sans Arabic"))
(when (member "Noto Sans Hebrew" (font-family-list))
  (set-fontset-font t 'arabic "Noto Sans Hebrew"))
;; Africa: ሠላም
(when (member "Noto Sans Ethiopic" (font-family-list))
  (set-fontset-font t 'ethiopic "Noto Sans Ethiopic"))

;; Default font is Ubuntu Mono (and Ubuntu Sans for variable-pitch)
;; If Ubuntu Mono or Ubuntu Sans are not available, use the default Emacs face
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
                      :weight 'regular))

;; Ignore X resources; its settings would be redundant with the other settings
;; in this file and can conflict with later config (particularly where the
;; cursor color is concerned).
(advice-add #'x-apply-session-resources :override #'ignore)
;;+EarlyFontSetup

;; AfterInitHook
(add-hook 'after-init-hook
          `(lambda ()
             (setq gc-cons-threshold 67108864 ; 64mb
                   gc-cons-percentage 0.1
                   file-name-handler-alist file-name-handler-alist-original)
             (garbage-collect)) t)
;; -AfterInitHook
