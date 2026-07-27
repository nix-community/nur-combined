;;; config-projects.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Project related configuration.
;;; Code:

(use-package project
  :bind (("C-x p v" . vde-project-magit-status)
         ("C-x p s" . vde-project-vterm)
         ("C-x p X" . vde/run-in-project-vterm))
  :config
  (setq vde/project-local-identifier '(".project")) ;; "go.mod"
  (setq project-switch-commands
        '((?f "File" project-find-file)
          (?g "Grep" project-find-regexp)
          (?d "Dired" project-dired)
          (?b "Buffer" project-switch-to-buffer)
          (?q "Query replace" project-query-replace-regexp)
          (?m "Magit" vde-project-magit-status)
          (?e "Eshell" project-eshell)
          (?s "Vterm" vde-project-vterm)))

  (defun vde/project-try-local (dir)
    "Determine if DIR is a non-VC project."
    (if-let ((root (if (listp vde/project-local-identifier)
                       (seq-some (lambda (n)
                                   (locate-dominating-file dir n))
                                 vde/project-local-identifier)
                     (locate-dominating-file dir vde/project-local-identifier))))
        (cons 'local root)))
  (cl-defmethod project-root ((project (head local)))
    (cdr project))

  (cl-defmethod project-root ((project (eql nil))) nil)

  (add-hook 'project-find-functions #'vde/project-try-local)

  :init
  (setq-default project-compilation-buffer-name-function 'project-prefixed-buffer-name)
  (defun vde-project-magit-status ()
    "Run `magit-status' on project."
    (interactive)
    (magit-status (vde-project--project-current)))

  (defun vde-project-vterm (&optional command)
    "Run `vterm' on project.
If a buffer already exists for running a vterm shell in the project's root,
switch to it. Otherwise, create a new vterm shell."
    (interactive)
    (let* ((default-directory (vde-project--project-current))
           (default-project-vterm-name (project-prefixed-buffer-name "vterm"))
           (vterm-buffer (get-buffer default-project-vterm-name)))
      (if (and vterm-buffer (not current-prefix-arg))
          (pop-to-buffer-same-window vterm-buffer)
        (let* ((cd-cmd (concat " cd " (shell-quote-argument default-directory))))
          (vterm default-project-vterm-name)
          (with-current-buffer vterm-buffer
            (vterm-send-string cd-cmd)
            (vterm-send-return))))
      (when command
        (vterm-send-string command)
        (vterm-send-return))))
  (defun vde/run-in-project-vterm ()
    (interactive)
    (let* ((default-directory (vde-project--project-current))
           (default-project-vterm-name (project-prefixed-buffer-name "vterm"))
           (vterm-buffer (get-buffer default-project-vterm-name)))
      (vde-project-vterm (read-string "Command: "))))
  )

(use-package conner
  :bind (("C-x p C" . conner-run-project-command))
  :init
  (require 'vterm))

(use-package project-x
  :after project
  :config
  (add-hook 'project-find-functions 'project-x-try-local 90)
  (add-hook 'kill-emacs-hook 'project-x--window-state-write)
  (add-to-list 'project-switch-commands
               '(?j "Restore windows" project-x-windows) t)
    :bind (("C-x p w" . project-x-window-state-save)
           ("C-x p j" . project-x-window-state-load)))

(provide 'config-projects)
;;; config-projects.el ends here
