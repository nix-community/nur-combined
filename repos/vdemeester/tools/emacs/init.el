;; Initialization
;; 
;; I am using the [[https://archive.casouri.cat/note/2020/painless-transition-to-portable-dumper/index.html][portable dump]] feature (/to speed things up/) *but* I want to also start
;; without =pdump=, so I need to take both cases into account.


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



;; First thing first, let's define a =emacs-start-time= constant to be able to compute the
;; time Emacs took to start.


(defconst emacs-start-time (current-time))



;; My configuration do not support Emacs version lower than 26.


(let ((minver 26))
  (unless (>= emacs-major-version minver)
    (error "Your Emacs is too old -- this configuration requires v%s or higher" minver)))



;; One thing though, I am currently not necessarily running Emacs 27, so I am going to need
;; to have the same configuration in ~init.el~ for a little bit of time.
;; 
;; /Note: the lowest emacs version I wanna support is 26 (as of today, might evolve)/


;; load early-init.el before Emacs 27.0
(unless (>= emacs-major-version 27)
  (message "Early init: Emacs Version < 27.0")
  (load (expand-file-name "early-init.el" user-emacs-directory)))



;; We also want our configuration to be working the same on any computer, this means we want
;; to define every option by ourselves, not relying on default files (~default.el~) that
;; would be set by our distribution. This is where =inhibit-default-init= comes into play,
;; setting it to non-nil inhibit loading the ~default~ library.
;; 
;; We also want to inhibit some initial default start messages and screen. The default screen
;; will be as bare as possible.


(setq inhibit-default-init t)           ; Disable the site default settings

(setq inhibit-startup-message t
      inhibit-startup-screen t)



;; Let's also use =y= or =n= instead of =yes= and =no= when exiting Emacs.


(setq confirm-kill-emacs #'y-or-n-p)



;; One last piece to the puzzle is the default mode. Setting it to fundamental-mode means we
;; won't load any /heavy/ mode at startup (like =org-mode=). We also want this scratch buffer
;; to be empty, so let's set it as well


(setq initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

;; Unicode all the way
;; :PROPERTIES:
;; :CUSTOM_ID: h:df45a01a-177d-4909-9ce7-a5423e0ea20f
;; :END:
;; 
;; By default, all my systems are configured and support =utf-8=, so let's just make it a
;; default in Emacs ; and handle special case on demand.


(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-language-environment 'utf-8)
(set-selection-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)

;; Package management with =use-package=
;; :PROPERTIES:
;; :CUSTOM_ID: h:112262a1-dd4d-4a50-a9e2-85b36bbbd95b
;; :END:
;; 
;; =use-package= is a tool that streamlines the configuration of packages. It handles
;; everything from assigning key bindings, setting the value of customisation options,
;; writing hooks, declaring a package as a dependency for another, and so on.
;; 
;; #+begin_quote
;; The =use-package= macro allows you to isolate package configuration in your =.emacs= file
;; in a way that is both performance-oriented and, well, tidy.  I created it because I have
;; over 80 packages that I use in Emacs, and things were getting difficult to manage.  Yet
;; with this utility my total load time is around 2 seconds, with no loss of functionality!
;; #+end_quote
;; 
;; With =use-package= we can improve the start-up performance of Emacs in a few fairly simple
;; ways. Whenever a command is bound to a key it is configured to be loaded only once
;; invoked. Otherwise we can specify which functions should be autoloaded by means of the
;; =:commands= keyword.
;; 
;; We need to setup the emacs package system and install =use-package= if not present
;; already.


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

;; Early environment setup
;; 
;; I want to *force* ==SSH_AUTH_SOCK= in Emacs to use my gpg-agent.


(setenv "SSH_AUTH_SOCK" "/run/user/1000/gnupg/S.gpg-agent.ssh")

;; =custom.el=
;; :PROPERTIES:
;; :CUSTOM_ID: h:1ddaf27e-ff7c-424e-8615-dd0bd22b685f
;; :END:
;; 
;; When you install a package or use the various customisation interfaces to tweak things to
;; your liking, Emacs will append a piece of elisp to your init file. I prefer to have that
;; stored in a separate file.


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

;; Remove built-in =org-mode=
;; :PROPERTIES:
;; :CUSTOM_ID: h:9462c0d7-03be-4231-8f22-ce1a04be32b1
;; :END:
;; 
;; I want to make sure I am using the installed version of =orgmode= (from my org
;; configuration) instead of the built-in one. To do that safely, let's remove the built-in
;; version out of the load path.


(require 'cl-seq)
(setq load-path
      (cl-remove-if
       (lambda (x)
         (string-match-p "org$" x))
       load-path))

;; Loading configuration files
;; :PROPERTIES:
;; :CUSTOM_ID: h:d6aebc56-aadb-4b01-8404-bb922d12f8a8
;; :END:
;; 
;; This =org-mode= document /tangles/ into several files in different folders :
;; - ~config~ for my configuration
;; - ~lisp~ for imported code or library I've written and not yet published
;; 
;; I used to load them by hand in the ~init.el~ file, which is very cumbersome, so let's try
;; to automatically load them. I want to first load the file in the ~lisp~ folder as they are
;; potentially used by my configuration (in ~config~).
;; 
;; Let's define some functions that would do the job.


(defun vde/el-load-dir (dir)
  "Load el files from the given folder"
  (let ((files (directory-files dir nil "\.el$")))
    (while files
      (load-file (concat dir (pop files))))))

(defun vde/short-hostname ()
  "Return hostname in short (aka wakasu.local -> wakasu)"
  (string-match "[0-9A-Za-z-]+" system-name)
  (substring system-name (match-beginning 0) (match-end 0)))



;; Let's define some constants early, based on the system, and the environment, to be able to
;; use those later on to skip some package or change some configuration accordingly.


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



;; Now, in order to load ~lisp~ and ~config~ files, it's just a matter of calling this
;; function with the right argument.


(add-to-list 'load-path (concat user-emacs-directory "lisp/"))
(add-to-list 'load-path (concat user-emacs-directory "lisp/vorg"))
(require 'init-func)
(vde/el-load-dir (concat user-emacs-directory "/config/"))



;; Finally, I want to be able to load files for a specific machine, in case I need it (not
;; entirely sure why yet but…)


(if (file-exists-p (downcase (concat user-emacs-directory "/hosts/" (vde/short-hostname) ".el")))
    (load-file (downcase (concat user-emacs-directory "/hosts/" (vde/short-hostname) ".el"))))

;; Counting the time of loading
;; :PROPERTIES:
;; :CUSTOM_ID: h:2b645e95-6776-4f5b-a318-e5a915943881
;; :END:


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
