;;; config-search.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Search related configuration
;;; Code:

;; UseISearch
(use-package isearch
  :config
  (setq-default search-whitespace-regexp ".*?"
                isearch-lax-whitespace t
                isearch-regexp-lax-whitespace nil)
  (defun stribb/isearch-region (&optional not-regexp no-recursive-edit)
    "If a region is active, make this the isearch default search
pattern."
    (interactive "P\np")
    (when (use-region-p)
      (let ((search (buffer-substring-no-properties
                     (region-beginning)
                     (region-end))))
        (message "stribb/ir: %s %d %d" search (region-beginning) (region-end))
        (setq deactivate-mark t)
        (isearch-yank-string search))))
  (advice-add 'isearch-forward-regexp :after 'stribb/isearch-region)
  (advice-add 'isearch-forward :after 'stribb/isearch-region)
  (advice-add 'isearch-backward-regexp :after 'stribb/isearch-region)
  (advice-add 'isearch-backward :after 'stribb/isearch-region)

  (defun contrib/isearchp-remove-failed-part-or-last-char ()
    "Remove failed part of search string, or last char if successful.
Do nothing if search string is empty to start with."
    (interactive)
    (if (equal isearch-string "")
        (isearch-update)
      (if isearch-success
          (isearch-delete-char)
        (while (isearch-fail-pos) (isearch-pop-state)))
      (isearch-update)))

  (defun contrib/isearch-done-opposite-end (&optional nopush edit)
    "End current search in the opposite side of the match.
Particularly useful when the match does not fall within the
confines of word boundaries (e.g. multiple words)."
    (interactive)
    (funcall #'isearch-done nopush edit)
    (when isearch-other-end (goto-char isearch-other-end)))
  :bind (("M-s M-o" . multi-occur)
         :map isearch-mode-map
         ("DEL" . contrib/isearchp-remove-failed-part-or-last-char)
         ("<C-return>" . contrib/isearch-done-opposite-end)))
;; -UseISearch

;; UseGrep
(use-package grep
  :commands (find-grep grep find-grep-dired find-name-dired)
  :bind (("M-s n" . find-name-dired)
         ("M-s F" . find-grep)
         ("M-s G" . grep)
         ("M-s d" . find-grep-dired))
  :hook ((hook-mode . toggle-truncate-lines))
  :config
  (add-to-list 'grep-find-ignored-directories "auto")
  (add-to-list 'grep-find-ignored-directories "elpa"))
;; -UseGrep

;; UseWgrep
(use-package wgrep
  :commands (wgrep-change-to-wgrep-mode)
  :defer 2
  :custom
  (wgrep-auto-save-buffer t)
  (wgrep-change-readonly-file t))
;; -UseWgrep

;; UseRG
(use-package rg
  :if *rg*
  :commands (rg rg-project rg-dwim)
  :bind (("M-s r r" . rg)
         ("M-s r p" . rg-project)
         ("M-s r s" . rg-dwiw))
  :config
  (with-eval-after-load 'projectile
    (defalias 'projectile-ripgrep #'rg-project)))
;; -UseRG

(provide 'config-search)
;;; config-search.el ends here
