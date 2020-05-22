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
;; -DisableUI

;; GarbageCollection
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)
;; -GarbageCollection

;; FileNameHandler
(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
;; -FileNameHandler

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
