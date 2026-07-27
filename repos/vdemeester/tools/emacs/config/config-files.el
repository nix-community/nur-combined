;;; config-files.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Files related configurations
;;; Code:

;; (use-package autoinsert
;;   :init
;;   (setq-default auto-insert-query nil
;;                 auto-insert-alist nil)
;;   :config
;;   (auto-insert-mode 1))

(require 'hardhat)
(global-hardhat-mode)

(use-package files
  :commands (revert-buffer)
  :bind (("<f5>" . revert-buffer))
  :config
  (setq-default view-read-only t))

(use-package envrc
  :defer 2
  :if (executable-find "direnv")
  :bind (:map envrc-mode-map
              ("C-c e" . envrc-command-map))
  :config (envrc-global-mode))

(use-package highlight-indentation
  :unless noninteractive
  :commands (highlight-indentation-mode highlight-indentation-current-column-mode)
  :config
  (set-face-background 'highlight-indentation-face "#e3e3d3")
  (set-face-background 'highlight-indentation-current-column-face "#c3b3b3"))

(defun vde/delete-this-file ()
  "Delete the current file, and kill the buffer."
  (interactive)
  (or (buffer-file-name) (error "No file is currently being edited"))
  (when (yes-or-no-p (format "Really delete '%s'?"
                             (file-name-nondirectory buffer-file-name)))
    (delete-file (buffer-file-name))
    (kill-this-buffer)))

(defun vde/rename-this-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (if (get-buffer new-name)
        (message "A buffer named '%s' already exists!" new-name)
      (progn
        (when (file-exists-p filename)
          (rename-file filename new-name 1))
        (rename-buffer new-name)
        (set-visited-file-name new-name)))))

(bind-key "C-c f D" #'vde/delete-this-file)
(bind-key "C-c f R" #'vde/rename-this-file-and-buffer)

;; Additional bindings for built-ins
(bind-key "C-c f v d" #'add-dir-local-variable)
(bind-key "C-c f v l" #'add-file-local-variable)
(bind-key "C-c f v p" #'add-file-local-variable-prop-line)

(defun vde/reload-dir-locals-for-current-buffer ()
  "Reload dir locals for the current buffer."
  (interactive)
  (let ((enable-local-variables :all))
    (hack-dir-local-variables-non-file-buffer)))

(defun vde/reload-dir-locals-for-all-buffers-in-this-directory ()
  "Reload dir-locals for all buffers in current buffer's `default-directory'."
  (interactive)
  (let ((dir default-directory))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (equal default-directory dir))
        (vde/reload-dir-locals-for-current-buffer)))))

(bind-key "C-c f v r" #'vde/reload-dir-locals-for-current-buffer)
(bind-key "C-c f v r" #'vde/reload-dir-locals-for-all-buffers-in-this-directory)

(provide 'config-files)
;;; config-files.el ends here
