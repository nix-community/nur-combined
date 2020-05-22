;;; docs.el --- Docs functions -*- lexical-binding: t; -*-
;; Author: Vincent Demeester <vincent@sbr.pm>

;;; Commentary:
;; This contains a group of function to update docs/ org includes.
(require 'init-func)

;;; Code:
(defun update-docs ()
  "Updates #+INCLUDE in docs/ org-mode files"
  (mapc (lambda (x) (update-org-include x))
        (directory-files-recursively "docs" "\.org$")))

(defun update-org-include (file)
  "Updates #+INCLUDE in docs/ org-mode of FILE."
  (with-current-buffer (find-file-noselect file)
    (save-and-update-includes)))

(provide 'docs)
;;; docs.el ends here
