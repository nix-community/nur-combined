;;; ol-github.el --- Links to GitHub -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Vincent Demeester

;; Author: Vincent Demeester <vincent@sbr.pm>
;; Keywords: org link github
;; Version: 0.1
;; URL: https://gitlab.com/vdemeester/vorg
;; Package-Requires: ((emacs "26.0") (org "9.0"))
;;
;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3.0, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:

;; This file implements links to GitHub from within Org mode.
;; gh:tektoncd/pipeline   : project
;; gh:tektoncd/pipeline#1 : issue or pr #1

;;; Code:

(require 'ol)

;; Install the link type
(org-link-set-parameters "gh"
                         :follow #'org-github-follow-link
                         :export #'org-github-export
                         :face '(:foreground "DimGrey" :underline t))


(defun org-github-export (link description format)
  "Export a github page link from Org files."
  (let ((path (org-github-get-url link))
        (desc (or description link)))
    (cond
     ((eq format 'html) (format "<a hrefl=\"_blank\" href=\"%s\">%s</a>" path desc))
     ((eq format 'latex) (format "\\href{%s}{%s}" path desc))
     ((eq format 'texinfo) (format "@uref{%s,%s}" path desc))
     ((eq format 'ascii) (format "%s (%s)" desc path))
     (t path))))

(defun org-github-follow-link (issue)
  "Browse github issue/pr specified."
  (browse-url (org-github-get-url issue)))

(defun org-github-get-url (path)
  "Translate org-mode link `gh:foo/bar#1' to github url."
  (setq expressions (split-string path "#"))
  (setq project (nth 0 expressions))
  (setq issue (nth 1 expressions))
  (if issue
      (format "https://github.com/%s/issues/%s" project issue)
    (format "https://github.com/%s" project)))

(provide 'ol-github)
;;; ol-github.el ends here
