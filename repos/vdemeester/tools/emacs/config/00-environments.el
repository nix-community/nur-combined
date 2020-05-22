;;; 00-environments.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Setup environment variables for Emacs
;;; Code:

;; We shouldn't need that, so it's disabled for now
(use-package exec-path-from-shell
  :disabled
  :if (display-graphic-p)
  :unless (or (eq system-type 'windows-nt) (eq system-type 'gnu/linux))
  :config
  (setq exec-path-from-shell-variables
        '("PATH"               ; Full path
          "INFOPATH"           ; Info directories
          "GOPATH"             ; Golang path
          ))
  (exec-path-from-shell-initialize))

(setenv "PAGER" "cat")
(setenv "TERM" "xterm-256color")

;;; 00-environments.el ends here
