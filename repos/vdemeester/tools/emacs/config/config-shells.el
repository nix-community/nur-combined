;;; config-shells.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Shell scripting
;;; Code:

(use-package shell
  :commands (shell)
  :bind (("<f1>"      . shell)
         (:map shell-mode-map
               ("<tab>" . completion-at-point)))
  :config
  (setq-default explicit-shell-file-name "zsh"
                shell-file-name "zsh")
  (unbind-key "C-c C-l" shell-mode-map)
  (bind-key "C-c C-l" #'counsel-shell-history shell-mode-map))

(defun run-in-compile (base-cmd &rest ARGS)
  "Use `compile' to run the BASE-CMD and ARGS, from eshell."
  (compile (concat base-cmd " " (apply #'concat ARGS))))

;; TODO: understand and rework eshell completion
(use-package eshell
  :commands (eshell eshell-here)
  :bind* ("C-x m t" . eshell-here)
  :config
  (defun eshell/make (&rest ARGS)
    "Shortcut to more easily run builds in a compile buffer"
    (cond ((or (file-exists-p "Makefile")
	       (file-exists-p "makefile"))
	   (run-in-compile "make" ARGS))
	  ((file-exists-p "build.zig")
	   (run-in-compile "zig build"))
	  (t "No supported build system found.")))
  (defun eshell-here ()
    "Open EShell in the directory associated with the current buffer's file.
The EShell is renamed to match that directory to make multiple windows easier."
    (interactive)
    (let* ((parent (if (buffer-file-name)
                       (file-name-directory (buffer-file-name))
                     default-directory))
           (name   (car (last (split-string parent "/" t)))))
      (eshell "new")
      (rename-buffer (concat "*eshell: " name "*"))))

  ;; Handy aliases
  (defalias 'ff 'find-file)
  (defalias 'emacs 'find-file)
  (defalias 'e 'find-file)
  (defalias 'ec 'find-file)
  (defalias 'd 'dired)

  (defun eshell/gs (&rest args)
    (magit-status (pop args) nil)
    (eshell/echo))                      ; The echo command suppresses output

  (defun eshell/cdg ()
    "Change directory to the project's root."
    (eshell/cd (locate-dominating-file default-directory ".git")))

  (defun eshell/extract (file)
    "One universal command to extract FILE (for bz2, gz, rar, etc.)"
    (eshell-command-result (format "%s %s" (cond ((string-match-p ".*\.tar.bz2" file)
                                                  "tar xzf")
                                                 ((string-match-p ".*\.tar.gz" file)
                                                  "tar xzf")
                                                 ((string-match-p ".*\.bz2" file)
                                                  "bunzip2")
                                                 ((string-match-p ".*\.rar" file)
                                                  "unrar x")
                                                 ((string-match-p ".*\.gz" file)
                                                  "gunzip")
                                                 ((string-match-p ".*\.tar" file)
                                                  "tar xf")
                                                 ((string-match-p ".*\.tbz2" file)
                                                  "tar xjf")
                                                 ((string-match-p ".*\.tgz" file)
                                                  "tar xzf")
                                                 ((string-match-p ".*\.zip" file)
                                                  "unzip")
                                                 ((string-match-p ".*\.jar" file)
                                                  "unzip")
                                                 ((string-match-p ".*\.Z" file)
                                                  "uncompress")
                                                 (t
                                                  (error "Don't know how to extract %s" file)))
                                   file)))

  ;; From https://karthinks.com/software/jumping-directories-in-eshell/
  (defun eshell/j (&optional regexp)
    "Navigate to a previously visited directory in eshell, or to
any directory proferred by `consult-dir'."
    (let ((eshell-dirs (delete-dups
                        (mapcar 'abbreviate-file-name
                                (ring-elements eshell-last-dir-ring)))))
      (cond
       ((and (not regexp) (featurep 'consult-dir))
        (let* ((consult-dir--source-eshell `(:name "Eshell"
                                                   :narrow ?e
                                                   :category file
                                                   :face consult-file
                                                   :items ,eshell-dirs))
               (consult-dir-sources (cons consult-dir--source-eshell
                                          consult-dir-sources)))
          (eshell/cd (substring-no-properties
                      (consult-dir--pick "Switch directory: ")))))
       (t (eshell/cd (if regexp (eshell-find-previous-directory regexp)
                       (completing-read "cd: " eshell-dirs)))))))

  (add-hook
   'eshell-mode-hook
   (lambda ()
     (let ((ls (if (executable-find "exa") "exa" "ls")))
       (eshell/alias "ls" (concat ls " $*"))
       (eshell/alias "ll" (concat ls " -l $*"))
       (eshell/alias "l" (concat ls " -lah $*")))
     (eshell-smart-initialize)
     (eshell-dirs-initialize)
     (bind-keys :map eshell-mode-map
                ("C-c C-l"                . counsel-esh-history)
                ([remap eshell-pcomplete] . completion-at-point)
                )))

  ;; Use system su/sudo
  (with-eval-after-load "em-unix"
    '(progn
       (unintern 'eshell/su nil)
       (unintern 'eshell/sudo nil)))

  (add-hook 'eshell-mode-hook #'with-editor-export-editor))

(use-package em-prompt
  :after eshell
  :config
  (defun vde/eshell-quit-or-delete-char (arg)
    "Use C-d to either delete forward char or exit EShell."
    (interactive "p")
    (if (and (eolp) (looking-back eshell-prompt-regexp nil nil))
        (progn
          (eshell-life-is-too-much))
      (delete-char arg)))

  (add-hook 'eshell-mode-hook
            (lambda ()
              (bind-key "C-d"
                        #'vde/eshell-quit-or-delete-char eshell-mode-map))))

(use-package esh-mode
  :disabled
  :after eshell
  :bind (:map eshell-mode-map
              ("<tab>" . vde/esh-mode-completion-at-point))
  :config
  (setq-default eshell-scroll-to-bottom-on-input 'all)
  (defun vde/esh-mode-completion-at-point ()
    "Same as `completion-at-point' except for some commands."
    (interactive)
    ;; unbinding pcomplete/make gives a chance to `bash-completion'
    ;; to complete make rules. Bash-completion is indeed more
    ;; powerfull than `pcomplete-make'.
    (cl-letf (((symbol-function 'pcomplete/make) nil))
      (completion-at-point))))

(use-package em-smart
  :after eshell)
(use-package em-dirs
  :after eshell)

(use-package em-cmpl
  :after eshell
  :hook (eshell-mode . eshell-cmpl-initialize)
  :config
  (defun my/eshell-bash-completion ()
    (let ((bash-completion-nospace t))
      (while (pcomplete-here
              (nth 2 (bash-completion-dynamic-complete-nocomint
                      (save-excursion (eshell-bol) (point))
                      (point)))))))
  (when (require 'bash-completion nil t)
    (setq eshell-default-completion-function #'my/eshell-bash-completion))

  (add-to-list 'eshell-command-completions-alist
               '("gunzip" "gz\\'"))
  (add-to-list 'eshell-command-completions-alist
               '("tar" "\\(\\.tar|\\.tgz\\|\\.tar\\.gz\\)\\'")))

(use-package em-hist
  :after eshell
  :config (setq eshell-hist-ignoredups t))

(use-package em-tramp
  :after eshell)

(use-package em-term
  :after eshell
  :config
  (add-to-list 'eshell-visual-commands "ssh")
  (add-to-list 'eshell-visual-commands "htop")
  (add-to-list 'eshell-visual-commands "top")
  (add-to-list 'eshell-visual-commands "tail")
  (add-to-list 'eshell-visual-commands "npm")
  (add-to-list 'eshell-visual-commands "ncdu"))

(use-package em-banner
  :after eshell
  :config
  (setq eshell-banner-message "
  Welcome to the Emacs

                         _/                  _/  _/
      _/_/      _/_/_/  _/_/_/      _/_/    _/  _/
   _/_/_/_/  _/_/      _/    _/  _/_/_/_/  _/  _/
  _/            _/_/  _/    _/  _/        _/  _/
   _/_/_/  _/_/_/    _/    _/    _/_/_/  _/  _/

"))

(use-package eshell-prompt-extras
  :after eshell
  :custom
  (eshell-highlight-prompt nil)
  (eshell-prompt-function 'vde-theme-lambda)
  :config
  (setq epe-path-style 'fish
	epe-fish-path-max-len 20)
  (defun vde-kubernetes-current-context ()
    "Return the current context"
    (if (not (string-empty-p (getenv "KUBECONFIG")))
        (epe-trim-newline (shell-command-to-string (concat
                                                    "env KUBECONFIG="
                                                    (getenv "KUBECONFIG")
                                                    " kubectl config current-context")))
      (epe-trim-newline (shell-command-to-string "kubectl config current-context"))))
  (defun vde-kubernetes-p ()
    "If you have kubectl install and a config set,
using either KUBECONFIG or ~/.kube/config"
    (and (eshell-search-path "kubectl")
         (not (string-empty-p (vde-kubernetes-current-context)))
         (not (string-match-p "error: current-context is not set" (vde-kubernetes-current-context)))))
  ;; From epe-theme-lambda
  (defun vde-theme-lambda ()
    "A eshell-prompt lambda theme."
    (setq eshell-prompt-regexp "^[^#\nλ]*[#λ] ")
    (concat
     (when (epe-remote-p)
       (epe-colorize-with-face
        (concat (epe-remote-user) "@" (epe-remote-host) " ")
        'epe-remote-face))
     (when (and epe-show-python-info (bound-and-true-p venv-current-name))
       (epe-colorize-with-face (concat "(" venv-current-name ") ") 'epe-venv-face))
     (let ((f (cond ((eq epe-path-style 'fish) 'epe-fish-path)
                    ((eq epe-path-style 'single) 'epe-abbrev-dir-name)
                    ((eq epe-path-style 'full) 'abbreviate-file-name))))
       (epe-colorize-with-face (funcall f (eshell/pwd)) 'epe-dir-face))
     (when (epe-git-p)
       (concat
        (epe-colorize-with-face ":" 'epe-dir-face)
        (epe-colorize-with-face
         (concat (epe-git-branch)
                 (epe-git-dirty)
                 (epe-git-untracked)
                 (let ((unpushed (epe-git-unpushed-number)))
                   (unless (= unpushed 0)
                     (concat ":" (number-to-string unpushed)))))
         'epe-git-face)))
     (when (vde-kubernetes-p)
       (concat (epe-colorize-with-face " (" 'epe-dir-face)
               (epe-colorize-with-face (vde-kubernetes-current-context) 'epe-dir-face)
               (epe-colorize-with-face ")" 'epe-dir-face)))
     (epe-colorize-with-face " λ" 'epe-symbol-face)
     (epe-colorize-with-face (if (= (user-uid) 0) "#" "") 'epe-sudo-symbol-face)
     " ")))

(use-package eat
  :init (setq eat-kill-buffer-on-exit t
	      eat-enable-yank-to-terminal t)
  :hook ((eshell-mode . eat-eshell-mode)
	 (eshell-mode . eat-eshell-visual-command-mode)))

(use-package xterm-color
  :after eshell
  :init
  ;; (setq comint-output-filter-functions
  ;;       (remove 'ansi-color-process-output comint-output-filter-functions))
  (add-hook 'shell-mode-hook
            (lambda ()
              ;; Disable font-locking in this buffer to improve performance
              (font-lock-mode -1)
              ;; Prevent font-locking from being re-enabled in this buffer
              (make-local-variable 'font-lock-function)
              (setq font-lock-function (lambda (_) nil))
              (add-hook 'comint-preoutput-filter-functions 'xterm-color-filter nil t)))
  (add-hook 'eshell-before-prompt-hook
            (lambda ()
              (setenv "TERM" "xterm-256color")
              (setq xterm-color-preserve-properties t)))
  (add-to-list 'eshell-preoutput-filter-functions 'xterm-color-filter)
  (setq eshell-output-filter-functions (remove 'eshell-handle-ansi-color eshell-output-filter-functions))
  (setq compilation-environment '("TERM=xterm-256color")))

(use-package vterm
  :commands (vterm vde/vterm-toggle)
  :bind (("C-c t v" . vde/vterm-toggle)
         ("C-c t r" . vde/run-in-vterm))
  :custom
  (vterm-kill-buffer-on-exit t)
  :config
  (defun vde/vterm-tramp-get-method-parameter (method param)
    "Return the method parameter PARAM.
If the `tramp-methods' entry does not exist, return NIL."
    (let ((entry (assoc param (assoc method tramp-methods))))
      (when entry (cadr entry))))
  (add-hook 'vterm-set-title-functions 'vterm--rename-buffer-as-title)
  ;; TODO: hook into projectile-run-vterm instead
  ;; Also, look into vterm-toggle way of doing things.. I thing it is trying to be too smart about it..
  ;; I prefer an easy projectile integration (or projects integration)
  (defun vde/vterm ()
    ""
    (interactive)
    (let* ((dir (expand-file-name default-directory))
           cd-cmd cur-host vterm-dir vterm-host cur-user cur-port remote-p cur-method login-cmd)
      (if (ignore-errors (file-remote-p dir))
          (with-parsed-tramp-file-name dir nil
            (setq remote-p t)
            (setq cur-host host)
            (setq cur-method (tramp-find-method method user cur-host))
            (setq cur-user (or (tramp-find-user cur-method user cur-host) ""))
            (setq cur-port (or port ""))
            (setq dir localname))
        (setq cur-host (system-name)))
      (setq login-cmd (vde/vterm-tramp-get-method-parameter cur-method 'tramp-login-program))
      (setq cd-cmd (concat " cd " (shell-quote-argument dir)))
      (setq shell-buffer (format "vterm %s %s" cur-host dir))
      (if (buffer-live-p shell-buffer)
          (switch-to-buffer shell-buffer)
        (progn
          (message (format "buffer '%s' doesn't exists" shell-buffer))
          (vterm shell-buffer)
          (with-current-buffer shell-buffer
            (message (format "%s" remote-p))
            (when remote-p
              (let* ((method (if (string-equal login-cmd "ssh") "ssh" cur-method))
                     (login-opts (vde/vterm-tramp-get-method-parameter method 'tramp-login-args))
                     (login-shell (vde/vterm-tramp-get-method-parameter method 'tramp-remote-shell))
                     (login-shell-args (tramp-get-sh-extra-args login-shell))
                     ;; (vterm-toggle-tramp-get-method-parameter cur-method 'tramp-remote-shell)
                     (spec (format-spec-make
			                ?h cur-host ?u cur-user ?p cur-port ?c ""
			                ?l (concat login-shell " " login-shell-args)))
                     (cmd
                      (concat login-cmd " "
                              (mapconcat
		                       (lambda (x)
			                     (setq x (mapcar (lambda (y) (format-spec y spec)) x))
			                     (unless (member "" x) (string-join x " ")))
		                       login-opts " "))))
                (vterm-send-string cmd)
                (vterm-send-return)))
            (vterm-send-string cd-cmd)
            (vterm-send-return))))))
  (defun vde/vterm-toggle ()
    "Toggle between the main vterm buffer and the current buffer.
If you are in a vterm buffer, switch the window configuration
back to your code buffers. Otherwise, create at least one vterm
buffer if it doesn't exist already, and switch to it. On every
toggle, the current window configuration is saved in a register."
    (interactive)
    (if (eq major-mode 'vterm-mode)
        (jump-to-register ?W)
      ;; Save current window config and jump to shell
      (window-configuration-to-register ?W)
      (condition-case nil
          (jump-to-register ?Z)
        (error
         (vterm)
         (when (= (length (window-list)) 2)
           (other-window 1)
           (vterm 1)
           (other-window 1))))
      (window-configuration-to-register ?Z)))
  (buffer-name)
  (defun vde/run-in-vterm ()
    (interactive)
    (with-current-buffer "vterm"
      (vterm-send-string (read-string "Command: "))
      (vterm-send-C-j))))

(use-package multi-vterm
  :commands (multi-vterm multi-vterm-projectile multi-vterm-dedicated-toggle)
  :bind (("C-c t t" . multi-vterm-dedicated-toggle)
         ("C-c t p" . multi-vterm-prev)
         ("C-c t n" . multi-vterm-next)
         ("C-c t s" . multi-vterm)))
;; for fish in ansi-term
(add-hook 'term-mode-hook 'toggle-truncate-lines)

(use-package tramp
  :defer t
  :config
  (setq-default tramp-use-ssh-controlmaster-options nil ; Don't override SSH config.
                tramp-default-method "ssh") ; ssh is faster than scp and supports ports.
  (add-to-list 'tramp-remote-path "/run/current-system/sw/bin")
  (add-to-list 'tramp-remote-path "/etc/profiles/per-user/root/bin/")
  (add-to-list 'tramp-remote-path "/etc/profiles/per-user/vincent/bin/")
  (add-to-list 'tramp-remote-path "~/.nix-profile/bin")
  (add-to-list 'tramp-remote-path "~/bin")
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(defun generic-term-init ()
  (visual-line-mode -1)
  (setq-local global-hl-line-mode nil)
  (setq-local scroll-margin 0))

(add-hook 'term-mode-hook #'generic-term-init)
(add-hook 'shell-mode-hook #'generic-term-init)
(add-hook 'eshell-mode-hook #'generic-term-init)

(provide 'config-shells)
;;; config-shells.el ends here
