(menu-bar-mode 0)
(tool-bar-mode 0)
(setq make-backup-files nil)
(show-paren-mode)

(let (
    (kb-setup "~/WORKSPACE/zettel-emacs/setup.el"))
    (when (file-exists-p kb-setup)
        (load-file kb-setup)))

(setq org-roam-v2-ack t)

(add-hook 'after-init-hook (lambda ()
    (define-key (current-global-map) (kbd "C-c n f") 'org-roam-node-find)
    (define-key (current-global-map) (kbd "C-c n r") 'org-roam-node-random)
    (define-key (org-mode-map) (kbd "C-c n i") 'org-roam-node-insert)
    (define-key (org-mode-map) (kbd "C-c n o") 'org-id-get-create)
    (define-key (org-mode-map) (kbd "C-c n t") 'org-roam-tag-add)
    (define-key (org-mode-map) (kbd "C-c n a") 'org-roam-alias-add)
    (define-key (org-mode-map) (kbd "C-c n l") 'org-roam-buffer-toggle)))

(defun buffer-animate-string (text)
  "Animate a string in a new buffer then close"
    (let (
        (buf (get-buffer-create "*demo*")))
    (progn
        (switch-to-buffer buf)
        (erase-buffer)
        (sit-for 0)
        (animate-string text (/ (window-height) 2) (- (/ (window-width) 2) 12))
        (sit-for 5)
        (message "OK")
        (kill-buffer buf))))
