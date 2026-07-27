;;; ol-grep.el --- Links to Grep -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Vincent Demeester

;; Author: Vincent Demeester <vincent@sbr.pm>
;; Keywords: org link grep
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

;; This file implements links to Grep from within Org mode.
;; grep:orgmode         : run grep on current working dir with orgmode expression
;; grep:orgmode:config/ : run grep on config/ dir with orgmode expression

;;; Code:

(require 'ol)

;; Install the link type
(org-link-set-parameters "rg"
                         :follow #'org-grep-follow-link
                         :face '(:foreground "DarkRed" :underline t))

(defun org-grep-follow-link (issue)
  "Run `rgrep' with REGEXP and FOLDER as argument,
like this : [[grep:REGEXP:FOLDER]]."
  (setq expressions (split-string regexp ":"))
  (setq exp (nth 0 expressions))
  (grep-compute-defaults)
  (if (= (length expressions) 1)
      (progn
        (rgrep exp "*" (expand-file-name "./")))
    (progn
      (setq folder (nth 1 expressions))
      (rgrep exp "*" (expand-file-name folder)))))

(provide 'ol-grep)
;;; ol-grep.el ends here
