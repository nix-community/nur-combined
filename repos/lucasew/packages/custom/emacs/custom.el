(menu-bar-mode 0)
(tool-bar-mode 0)
(setq make-backup-files nil)
(show-paren-mode)

(let (
    (kb-setup "~/WORKSPACE/zettel-emacs/setup.el"))
    (when (file-exists-p kb-setup)
        (load-file kb-setup)))

(setq org-roam-v2-ack t)

(setq org-roam-ui-update-on-save t)
(setq org-roam-ui-follow t)
(setq org-roam-ui-open-on-start nil)

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

(defun browse-article-url (url &rest ignore)
  "Browse URL but using articleparser.win"
  (interactive "sURL: ")
  (browse-url (concat "https://articleparser.win/article?url=" (url-encode-url url))))

(defun find-file-and-paste-its-relative-filepath ()
  "Find some file and paste it's relative path in relation of the current file"
  (interactive)
  (let* (
	(dir (expand-file-name (file-name-directory (or buffer-file-name "./"))))
	(filename (helm-read-file-name dir)))
    (insert (file-relative-name filename dir))))
