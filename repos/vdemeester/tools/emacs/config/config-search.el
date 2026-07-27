;;; config-search.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Search related configuration
;;; Code:

;; UseISearch
(use-package isearch
  :unless noninteractive
  :config
  (defun my-project-search-from-isearch ()
    (interactive)
    (let ((query (if isearch-regexp
               isearch-string
             (regexp-quote isearch-string))))
      (isearch-update-ring isearch-string isearch-regexp)
      (let (search-nonincremental-instead)
        (ignore-errors (isearch-done t t)))
      (project-find-regexp query)))
  (defun my-occur-from-isearch ()
    (interactive)
    (let ((query (if isearch-regexp
		     isearch-string
		   (regexp-quote isearch-string))))
      (isearch-update-ring isearch-string isearch-regexp)
      (let (search-nonincremental-instead)
        (ignore-errors (isearch-done t t)))
      (occur query)))
  (setq-default search-whitespace-regexp ".*?"
                isearch-lax-whitespace t
                isearch-regexp-lax-whitespace nil
		isearch-lazy-count t
		lazy-count-prefix-format nil
		lazy-count-suffix-format "   (%s/%s)")
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
	 ("C-o" . my-occur-from-isearch)
	 ("C-f" . my-project-search-from-isearch)
	 ("C-d" . isearch-forward-symbol-at-point)
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
  (setq-default grep-template (string-join '("ugrep"
                                             "--color=always"
                                             "--ignore-binary"
                                             "--ignore-case"
                                             "--include=<F>"
                                             "--line-number"
                                             "--null"
                                             "--recursive"
                                             "--regexp=<R>")
                                           " "))
  (add-to-list 'grep-find-ignored-directories "auto")
  (add-to-list 'grep-find-ignored-directories "elpa"))
;; -UseGrep

;; UseWgrep
(use-package wgrep
  :unless noninteractive
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
         ("M-s r s" . rg-dwim))
  :config
  (setq rg-group-result t)
  (setq rg-hide-command t)
  (setq rg-show-columns nil)
  (setq rg-show-header t)
  (setq rg-default-alias-fallback "all")
  (cl-pushnew '("tmpl" . "*.tmpl") rg-custom-type-aliases)
  (cl-pushnew '("gotest" . "*_test.go") rg-custom-type-aliases)
  (defun vde/rg-buffer-name ()
    "Generate a rg buffer name from project if in one"
    (let ((p (project-root (project-current))))
      (if p
	  (format "rg: %s" (abbreviate-file-name p))
	"rg")))
  (setq rg-buffer-name #'vde/rg-buffer-name)
  
  ;; (when (f-dir-p "~/src/tektoncd/")
  ;;   (rg-define-search rg-projects-tektoncd
  ;;     "Search tektoncd (projects)."
  ;;     :dir "~/src/tektoncd/"
  ;;     :files "*.*"
  ;;     :menu ("Projects" "t" "tektoncd")))
  ;; (when (f-dir-p "~/src/home/")
  ;;   (rg-define-search rg-projects-home
  ;;     "Search home."
  ;;     :dir "~/src/home/"
  ;;     :files "*.*"
  ;;     :menu ("Projects" "h" "home")))
  )

;; -UseRG

(provide 'config-search)
;;; config-search.el ends here
