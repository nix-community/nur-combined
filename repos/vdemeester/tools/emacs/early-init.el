;;; early-init.el --- Early init configuration file -*- lexical-binding: t; -*-

;; Copyright (c) 2020-2023  Vincent Demeester <vincent@sbr.pm>

;; Author: Vincent Demeester <vincent@sbr.pm>
;; URL: https://git.sr.ht/~vdemeester/home
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1"))

;; This file is NOT part of GNU Emacs.

;; This file is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Prior to Emacs 27, the `init.el' was supposed to handle the
;; initialisation of the package manager, by means of calling
;; `package-initialize'.  Starting with Emacs 27, the default
;; behaviour is to start the package manager before loading the init
;; file.
;;

;; See my dotfiles: https://git.sr.ht/~vdemeester/home

;;; Code:

;; Do not initialize installed packages
(setopt package-enable-at-startup nil
	package-archives nil
	package-quickstart nil)
(setopt use-package-ensure-function 'ignore)

;; Do not resize the frame at this early stage
(setopt frame-inhibit-implied-resize t
	frame-resize-pixelwise t
	frame-title-format '("%b")) ;; do not add "GNU Emacs at …"

;; Disable GUI elements
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(horizontal-scroll-bar-mode -1)

(setopt use-dialog-box nil   ;; never use dialog-box (no mouse)
	use-file-dialog nil  ;; never use file dialog (gtk)
	use-short-answers t  ;; replace defalias yes-or-no-p
	read-answer-short t) ;; accepts single-character answer, similar to above

(setopt inhibit-startup-message t
	inhibit-startup-screen t
	inhibit-startup-echo-area-message user-login-name ; read the docstring
	inhibit-startup-buffer-menu t)

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

(defvar vde--file-name-handler-alist file-name-handler-alist)
(defvar vde--vc-handled-backends vc-handled-backends)
(setq file-name-handler-alist nil
      vc-handled-backends nil)


;; Ignore X resources; its settings would be redundant with the other settings
;; in this file and can conflict with later config (particularly where the
;; cursor color is concerned).
(advice-add #'x-apply-session-resources :override #'ignore)
(setopt inhibit-x-resources t)

;;
(when (getenv-internal "DEBUG")
  (setq init-file-debug t
	debug-on-error t))

;; - Resetting garbage collection and file-name-handler values.
(add-hook 'after-init-hook
          `(lambda ()
             (setq gc-cons-threshold 67108864 ; 64mb
                   gc-cons-percentage 0.1
                   file-name-handler-alist vde--file-name-handler-alist
		   vc-handled-backends vde--vc-handled-backends)
             (garbage-collect)) t)
