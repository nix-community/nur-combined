;;; init.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; init configuration file for GNU Emacs
;;; Code:

(defvar sbr-dumped nil
  "non-nil when a dump file is loaded (because dump.el sets this variable).")

(defmacro sbr-if-dump (then &rest else)
  "Evaluate IF if running with a dump file, else evaluate ELSE."
  (declare (indent 1))
  `(if sbr-dumped
       ,then
     ,@else))

(sbr-if-dump
    (progn
      (global-font-lock-mode)
      (transient-mark-mode)
      (setq load-path sbr-dumped-load-path))
  ;; add load-path’s and load autoload files
  (package-initialize))

;; +CheckVer
(let ((minver 26))
  (unless (>= emacs-major-version minver)
    (error "Your Emacs is too old -- this configuration requires v%s or higher" minver)))

(defconst emacs-start-time (current-time))

;; load early-init.el before Emacs 27.0
(unless (>= emacs-major-version 27)
  (message "Early init: Emacs Version < 27.0")
  (load (expand-file-name "early-init.el" user-emacs-directory)))
;; -CheckVer

;; Inhibit
(setq inhibit-default-init t)           ; Disable the site default settings

(setq inhibit-startup-message t
      inhibit-startup-screen t)
;; -Inhibit

;; Confirm
(setq confirm-kill-emacs #'y-or-n-p)
;; -Confirm

;; DefaultMode
(setq initial-major-mode 'fundamental-mode
      initial-scratch-message nil)
;; -DefaultMode

;; Unicode
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-language-environment 'utf-8)
(set-selection-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
;; -Unicode

;;; UsePackageSetup
(require 'package)

(setq package-archives
      '(("melpa" . "http://melpa.org/packages/")
        ("org" . "https://orgmode.org/elpa/")
        ("gnu" . "https://elpa.gnu.org/packages/")))

(setq package-archive-priorities
      '(("melpa" .  3)
        ("org" . 2)
        ("gnu" . 1)))

(require 'tls)

;; From https://github.com/hlissner/doom-emacs/blob/5dacbb7cb1c6ac246a9ccd15e6c4290def67757c/core/core-packages.el#L102
(setq gnutls-verify-error (not (getenv "INSECURE")) ; you shouldn't use this
      tls-checktrust gnutls-verify-error
      tls-program (list "gnutls-cli --x509cafile %t -p %p %h"
                        ;; compatibility fallbacks
                        "gnutls-cli -p %p %h"
                        "openssl s_client -connect %h:%p -no_ssl2 -no_ssl3 -ign_eof"))

;; Initialise the packages, avoiding a re-initialisation.
(unless (bound-and-true-p package--initialized)
  (setq package-enable-at-startup nil)
  (package-initialize))

(setq load-prefer-newer t)              ; Always load newer compiled files
(setq ad-redefinition-action 'accept)   ; Silence advice redefinition warnings

;; Init `delight'
(unless (package-installed-p 'delight)
  (package-refresh-contents)
  (package-install 'delight))

;; Configure `use-package' prior to loading it.
(eval-and-compile
  (setq use-package-always-ensure nil)
  (setq use-package-always-defer nil)
  (setq use-package-always-demand nil)
  (setq use-package-expand-minimally nil)
  (setq use-package-enable-imenu-support t))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
;; -UsePackageSetup

(setenv "SSH_AUTH_SOCK" "/run/user/1000/gnupg/S.gpg-agent.ssh")

;; CustomFile
(defconst vde/custom-file (locate-user-emacs-file "custom.el")
  "File used to store settings from Customization UI.")

(use-package cus-edit
  :config
  (setq
   custom-file vde/custom-file
   custom-buffer-done-kill nil          ; Kill when existing
   custom-buffer-verbose-help nil       ; Remove redundant help text
   custom-unlispify-tag-names nil       ; Show me the real variable name
   custom-unlispify-menu-entries nil)
  (unless (file-exists-p custom-file)
    (write-region "" nil custom-file))

  (load vde/custom-file 'no-error 'no-message))
;; -CustomFile

;; NoBuiltinOrg
(require 'cl-seq)
(setq load-path
      (cl-remove-if
       (lambda (x)
         (string-match-p "org$" x))
       load-path))
;; -NoBuiltinOrg

;; LoadCfgFunc
(defun vde/el-load-dir (dir)
  "Load el files from the given folder"
  (let ((files (directory-files dir nil "\.el$")))
    (while files
      (load-file (concat dir (pop files))))))

(defun vde/short-hostname ()
  "Return hostname in short (aka wakasu.local -> wakasu)"
  (string-match "[0-9A-Za-z-]+" system-name)
  (substring system-name (match-beginning 0) (match-end 0)))
;; -LoadCfgFunc

;; CfgConstant
(defconst *sys/gui*
  (display-graphic-p)
  "Are we running on a GUI Emacs ?")
(defconst *sys/linux*
  (eq system-type 'gnu/linux)
  "Are we running on a GNU/Linux system?")
(defconst *sys/mac*
  (eq system-type 'darwin)
  "Are we running on a Mac system?")
(defconst *sys/root*
  (string-equal "root" (getenv "USER"))
  "Are you a ROOT user?")
(defconst *nix*
  (executable-find "nix")
  "Do we have nix? (aka are we running in NixOS or a system using nixpkgs)")
(defconst *rg*
  (executable-find "rg")
  "Do we have ripgrep?")
(defconst *gcc*
  (executable-find "gcc")
  "Do we have gcc?")
(defconst *git*
  (executable-find "git")
  "Do we have git?")

(defvar *sys/full*
  (member (vde/short-hostname) '("wakasu" "naruhodo")) ; "naruhodo" <- put naruhodo back in
  "Is it a full system ?")
(defvar *sys/light*
  (not *sys/full*)
  "Is it a light system ?")
;; -CfgConstant

;; CfgLoad
(add-to-list 'load-path (concat user-emacs-directory "lisp/"))
(add-to-list 'load-path (concat user-emacs-directory "lisp/modus-themes"))
(add-to-list 'load-path (concat user-emacs-directory "lisp/vorg"))
(require 'init-func)
(vde/el-load-dir (concat user-emacs-directory "/config/"))
;; -CfgLoad

;; CfgHostLoad
(if (file-exists-p (downcase (concat user-emacs-directory "/hosts/" (vde/short-hostname) ".el")))
    (load-file (downcase (concat user-emacs-directory "/hosts/" (vde/short-hostname) ".el"))))
;; -CfgHostLoad

;; LastInit
(let ((elapsed (float-time (time-subtract (current-time)
                                          emacs-start-time))))
  (message "Loading %s...done (%.3fs)" load-file-name elapsed))

(add-hook 'after-init-hook
          `(lambda ()
             (let ((elapsed
                    (float-time
                     (time-subtract (current-time) emacs-start-time))))
               (message "Loading %s...done (%.3fs) [after-init]"
                        ,load-file-name elapsed))) t)
;; -LastInit

;;; init.el ends here
