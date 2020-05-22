;;; config-compile.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Generic compilation configuration
;;; Code:

;; UseCompile
(use-package compile
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
  (defun vde/goto-address-mode ()
    (unless (or (derived-mode-p 'grep-mode)
                (derived-mode-p 'ag-mode)
                (derived-mode-p 'rg-mode))
      (goto-address-mode t)))
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
  (add-hook 'compilation-filter-hook #'vde/colorize-compilation-buffer)
  (add-hook 'compilation-mode-hook #'vde/goto-address-mode))
;; -UseCompile

;; UseFlycheck
(use-package flycheck
  :if (not (eq system-type 'windows-nt))
  :hook (prog-mode . flycheck-mode)
  :commands (flycheck-mode flycheck-next-error flycheck-previous-error)
  :init
  (dolist (where '((emacs-lisp-mode-hook . emacs-lisp-mode-map)
                   (haskell-mode-hook    . haskell-mode-map)
                   (js2-mode-hook        . js2-mode-map)
                   (c-mode-common-hook   . c-mode-base-map)))
    (add-hook (car where)
              `(lambda ()
                 (bind-key "M-n" #'flycheck-next-error ,(cdr where))
                 (bind-key "M-p" #'flycheck-previous-error ,(cdr where)))))
  :config
  (defalias 'show-error-at-point-soon
    'flycheck-show-error-at-point)
  (setq-default flycheck-idle-change-delay 1.2
                ;; Remove newline checks, since they would trigger an immediate check
                ;; when we want the idle-change-delay to be in effect while editing.
                flycheck-check-syntax-automatically '(save
                                                      idle-change
                                                      mode-enabled))
  ;; Each buffer gets its own idle-change-delay because of the
  ;; buffer-sensitive adjustment above.
  (defun magnars/adjust-flycheck-automatic-syntax-eagerness ()
    "Adjust how often we check for errors based on if there are any.
  This lets us fix any errors as quickly as possible, but in a
  clean buffer we're an order of magnitude laxer about checking."
    (setq flycheck-idle-change-delay
          (if flycheck-current-errors 0.3 3.0)))
  (make-variable-buffer-local 'flycheck-idle-change-delay)
  (add-hook 'flycheck-after-syntax-check-hook
            #'magnars/adjust-flycheck-automatic-syntax-eagerness)
  (defun flycheck-handle-idle-change ()
    "Handle an expired idle time since the last change.
  This is an overwritten version of the original
  flycheck-handle-idle-change, which removes the forced deferred.
  Timers should only trigger inbetween commands in a single
  threaded system and the forced deferred makes errors never show
  up before you execute another command."
    (flycheck-clear-idle-change-timer)
    (flycheck-buffer-automatically 'idle-change)))
;; -UseFlycheck

(provide 'config-compile)
;;; config-compile.el ends here
