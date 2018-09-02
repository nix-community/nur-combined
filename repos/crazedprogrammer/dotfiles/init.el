(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))
(package-initialize)

(defun require-all (paths)
  (mapcar (lambda (path)
            (require path))
       paths))

(defun add-hooks (hooks function)
  (mapcar (lambda (hook)
            (add-hook hook function))
    hooks))


; Packages that need to be required
(require-all
 '(evil
   linum-relative
   fiplr))

; GUI
(setq custom-safe-themes t)
(load-theme 'base16-chalk t)
(set-cursor-color "#c0c0c0")
(set-face-foreground 'font-lock-comment-face "#808080")
(set-face-background 'trailing-whitespace "#A01010")
(set-face-attribute 'default nil :height 100)
(tool-bar-mode -1)

; Evil mode and relative line numbers
(evil-mode t)
(setq linum-disabled-major-modes '(doc-view-mode))
(add-hooks '(find-file-hook lisp-interaction-mode-hook)
  (lambda () (unless (member major-mode linum-disabled-major-modes)
               (linum-relative-on))))

; Colourise and match parens
(setq show-paren-delay 0)
(show-paren-mode t)
(add-hook 'find-file-hook 'rainbow-delimiters-mode)

; No trailing whitespace
(add-hook 'find-file-hook (lambda () (setq show-trailing-whitespace t)))

; Recent files
(setq recentf-max-menu-items 25)
(setq recentf-save-file (file-truename "~/.emacs-recentf"))
(recentf-mode 1)

; Backup files
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

; File extensions
(setq auto-mode-alist (cons '("\\.ino$" . c++-mode) auto-mode-alist))


; Tabs
(setq-default indent-tabs-mode nil)
(setq lisp-indent-offset 2)

; Key bindings
(global-set-key "\M-n" 'recentf-open-files)
(global-set-key "\M-p" 'fiplr-find-file)
(global-set-key (kbd "C-S-v") 'clipboard-yank)

; Auto-complete
(ac-config-default)
(add-hook 'find-file-hook 'auto-complete-mode)

; Pandoc

(defun temp-path (extension)
  (concat "/tmp/emacs-" (number-to-string (random 99999)) "." extension))

(defun temp-write ()
  (let ((path (temp-path (file-name-extension buffer-file-name))))
    (append-to-file (buffer-string) nil path)
    path))

(defun display-output-pdf ()
  (interactive)
  (let ((input-path (temp-write))
        (output-path "/tmp/emacs-pdf-preview.pdf"))
    (shell-command (concat "pandoc -s --number-sections --table-of-contents -V geometry:margin=2cm -f markdown " input-path " -o " output-path))
    (delete-file input-path)
    (when (not (get-buffer (file-name-nondirectory output-path)))
      (split-window-below)
      (windmove-down)
      (find-file output-path))))

(global-auto-revert-mode 1)
