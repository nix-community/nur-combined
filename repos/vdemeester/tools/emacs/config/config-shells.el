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

;; TODO: understand and rework eshell completion
(use-package eshell
  :commands (eshell eshell-here)
  :bind* ("C-x m t" . eshell-here)
  :config
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

  (defun eshell/d ()
    "Open a dired instance of the current working directory."
    (dired "."))

  (defun eshell/gs (&rest args)
    (magit-status (pop args) nil)
    (eshell/echo))                      ; The echo command suppresses output

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

  (add-hook
   'eshell-mode-hook
   (lambda ()
     (let ((ls (if (executable-find "exa") "exa" "ls")))
       (eshell/alias "ls" (concat ls " --color=always $*"))
       (eshell/alias "ll" (concat ls " --color=always -l $*"))
       (eshell/alias "l" (concat ls " --color=always -lah $*")))
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

(use-package esh-autosuggest
  :after eshell
  :hook (eshell-mode . esh-autosuggest-mode))

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
  :commands (vterm)
  :custom
  (vterm-kill-buffer-on-exit t))

;; for fish in ansi-term
(add-hook 'term-mode-hook 'toggle-truncate-lines)

(use-package tramp
  :defer t
  :config
  (add-to-list 'tramp-remote-path "/run/current-system/sw/bin")
  (add-to-list 'tramp-remote-path "~/.nix-profile/bin")
  (add-to-list 'tramp-remote-path "~/bin"))

(defun generic-term-init ()
  (visual-line-mode -1)
  (setq-local global-hl-line-mode nil)
  (setq-local scroll-margin 0))

(add-hook 'term-mode-hook #'generic-term-init)
(add-hook 'shell-mode-hook #'generic-term-init)
(add-hook 'eshell-mode-hook #'generic-term-init)

(provide 'setup-shells)
