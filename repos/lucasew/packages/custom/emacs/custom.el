(menu-bar-mode 0)
(tool-bar-mode 0)
(setq make-backup-files nil)
(show-paren-mode)

(let (
    (kb-setup "~/WORKSPACE/zettel-emacs/setup.el"))
    (when (file-exists-p kb-setup)
        (load-file kb-setup)))

(setq org-roam-v2-ack t)
(message "Externo")
