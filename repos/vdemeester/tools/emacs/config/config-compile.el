;;; config-compile.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Generic compilation configuration
;;; Code:

(defun my-recompile (args)
  (interactive "P")
  (cond
   ((eq major-mode #'emacs-lisp-mode)
    (call-interactively 'eros-eval-defun))
   ((bound-and-true-p my-vterm-command)
    (my-vterm-execute-region-or-current-line my-vterm-command))
   ((get-buffer "*compilation*")
    (with-current-buffer"*compilation*"
      (recompile)))
   ((get-buffer "*Go Test*")
    (with-current-buffer "*Go Test*"
      (recompile)))
   ((and (eq major-mode #'go-mode)
         buffer-file-name
         (string-match
          "_test\\'" (file-name-sans-extension buffer-file-name)))
    (my-gotest-maybe-ts-run))
   ((and (get-buffer "*cargo-test*")
         (boundp 'my-rustic-current-test-compile)
         my-rustic-current-test-compile)
    (with-current-buffer "*cargo-test*"
      (rustic-cargo-test-run my-rustic-current-test-compile)))
   ((get-buffer "*cargo-run*")
    (with-current-buffer "*cargo-run*"
      (rustic-cargo-run-rerun)))
   ((get-buffer "*pytest*")
    (with-current-buffer "*pytest*"
      (recompile)))
   ((eq major-mode #'python-mode)
    (compile (concat python-shell-interpreter " " (buffer-file-name))))
   ((call-interactively 'compile))))

;; UseCompile
(use-package compile
  :unless noninteractive
  :commands (compile)
  :preface
  (autoload 'ansi-color-apply-on-region "ansi-color")

  (defvar compilation-filter-start)

  (defun vde/colorize-compilation-buffer ()
    (unless (or (derived-mode-p 'grep-mode)
                (derived-mode-p 'ag-mode)
                (derived-mode-p 'rg-mode))
      (let ((inhibit-read-only t))
        (ansi-color-apply-on-region compilation-filter-start (point)))))
  :config
  (setq-default compilation-scroll-output t
                ;; I'm not scared of saving everything.
                compilation-ask-about-save nil
                ;; Automatically scroll and jump to the first error
                ;; compilation-scroll-output 'next-error
                ;; compilation-scroll-output 'first-error
                ;; compilation-auto-jump-to-first-error t
                ;; Skip over warnings and info messages in compilation
                compilation-skip-threshold 2
                ;; Don't freeze when process reads from stdin
                compilation-disable-input t
                ;; Show three lines of context around the current message
                compilation-context-lines 3
                )
  (add-hook 'comint-output-filter-functions
            'comint-watch-for-password-prompt)
  (setq-default comint-password-prompt-regexp
                (concat
                 "\\("
                 "^Enter passphrase.*:"
                 "\\|"
                 "^Repeat passphrase.*:"
                 "\\|"
                 "[Pp]assword for '[a-z0-9_-.]+':"
                 "\\|"
                 "\\[sudo\\] [Pp]assword for [a-z0-9_-.]+:"
                 "\\|"
                 "[a-zA-Z0-9]'s password:"
                 "\\|"
                 "^[Pp]assword:"
                 "\\|"
                 "^[Pp]assword (again):"
                 "\\|"
                 ".*\\([Ww]ork\\|[Pp]ersonal\\).* password:"
                 "\\|"
                 "Password for '([^()]+)' GNOME keyring"
                 "\\|"
                 "Password for 'http.*github.*':"
                 "\\)"))
  (add-hook 'compilation-filter-hook #'vde/colorize-compilation-buffer))

(use-package emacs
  :bind
  (:map prog-mode-map
        ("C-M-<return>" . compile)
        ("C-<return>"   . my-recompile)))

(provide 'config-compile)
;;; config-compile.el ends here
