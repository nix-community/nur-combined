;;; project-func.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
(require 'project)

;;;###autoload
(defun vde-project--project-current ()
  "Return directory from `project-current' based on Emacs version."
  (if (>= emacs-major-version 29)
      (project-root (project-current))
    (cdr (project-current))))

(defun vde-project--project-root-or-default-directory ()
  "Return path to the project root *or* the default-directory."
  (cond
   ((and (featurep 'project) (project-current))
    (project-root (project-current)))
   (t default-directory)))

(provide 'project-func)
;;; project-func.el ends here
