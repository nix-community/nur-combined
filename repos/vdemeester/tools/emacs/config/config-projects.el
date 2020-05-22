;;; config-projects.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Project related configuration.
;;; Using projectile now, might use projects later
;;; Code:
(use-package projectile
  :commands
  (projectile-ack
   projectile-ag
   projectile-compile-project
   projectile-dired
   projectile-find-dir
   projectile-find-file
   projectile-find-tag
   projectile-test-project
   projectile-grep
   projectile-invalidate-cache
   projectile-kill-buffers
   projectile-multi-occur
   projectile-project-p
   projectile-project-root
   projectile-recentf
   projectile-regenerate-tags
   projectile-replace
   projectile-replace-regexp
   projectile-run-async-shell-command-in-root
   projectile-run-shell-command-in-root
   projectile-switch-project
   projectile-switch-to-buffer
   projectile-vc)
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (setq-default projectile-completion-system 'default
                ;; Do not track known projects automatically, instead call projectile-add-known-project
                projectile-track-known-projects-automatically nil)
  (projectile-mode)
  ;; Remove dead projects when Emacs is idle
  (run-with-idle-timer 10 nil #'projectile-cleanup-known-projects)
  (setq
   ;; Custom compilation buffer name function
   compilation-buffer-name-function (lambda (mode) (concat "*" (downcase mode) ": " (projectile-project-name) "*"))
   projectile-find-dir-includes-top-level t
   projectile-switch-project-action #'projectile-commander
   projectile-create-missing-test-files t
   projectile-mode-line '(:eval (format " Proj[%s]" (projectile-project-name))))
  (def-projectile-commander-method ?s
    "Open a *shell* buffer for the project"
    (projectile-run-eshell))
  (def-projectile-commander-method ?c
    "Run `compile' in the project"
    (projectile-compile-project nil)))

(provide 'config-projects)
;;; config-projects.el ends here
