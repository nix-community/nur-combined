;;; ol-gitlab.el --- Links to Gitlab -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Vincent Demeester

;; Author: Vincent Demeester <vincent@sbr.pm>
;; Keywords: org link gitlab
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

;; This file implements links to Gitlab from within Org mode.
;; gl:vdemeester/emacs-config    : project
;; gl:vdemeester/emacs-config#1  : issue #1
;; gl:vdemeester/emacs-config##1 : merge-request #1

;;; Code:

(require 'ol)

;; Install the link type
(org-link-set-parameters "gl"
                         :follow #'org-gitlab-follow-link
                         :export #'org-gitlab-export
                         :face '(:foreground "DimGrey" :underline t))


(defun org-gitlab-export (link description format)
  "Export a gitlab page link from Org files."
  (let ((path (org-gitlab-get-url link))
        (desc (or description link)))
    (cond
     ((eq format 'html) (format "<a hrefl=\"_blank\" href=\"%s\">%s</a>" path desc))
     ((eq format 'latex) (format "\\href{%s}{%s}" path desc))
     ((eq format 'texinfo) (format "@uref{%s,%s}" path desc))
     ((eq format 'ascii) (format "%s (%s)" desc path))
     (t path))))

(defun org-gitlab-follow-link (issue)
  "Browse gitlab issue/pr specified."
  (browse-url (org-gitlab-get-url issue)))

(defun org-gitlab-get-url (path)
  "Translate org-mode link `gh:foo/bar#1' to gitlab url."
  (setq expressions (split-string path "#"))
  (setq project (nth 0 expressions))
  (setq issue (nth 1 expressions))
  (setq mr (nth 2 expressions))
  (message (format "issue: %s" issue))
  (message (format "mr: %s" mr))
  (if (not (empty-string-p mr))
      (format "https://gitlab.com/%s/-/merge_requests/%s" project mr)
    (if (not (empty-string-p issue))
        (format "https://gitlab.com/%s/-/issues/%s" project issue)
      (format "https://gitlab.com/%s" project))))

(defun empty-string-p (string)
  "Return true if the STRING is empty or nil. Expects string type."
  (or (null string)
      (zerop (length (string-trim string)))))

(provide 'ol-gitlab)
;;; ol-gitlab.el ends here
