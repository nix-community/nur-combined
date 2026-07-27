;;; ol-rg.el --- Links to rg -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Vincent Demeester

;; Author: Vincent Demeester <vincent@sbr.pm>
;; Keywords: org link ripgrep rg.el
;; Version: 0.1
;; URL: https://gitlab.com/vdemeester/vorg
;; Package-Requires: ((emacs "26.0") (org "9.0") (rg "1.8.0"))
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

;; This file implements links to Ripgrep from within Org mode.
;; rg:orgmode             : run ripgrep on current working dir with orgmode expression
;; rg:orgmode:config/     : run ripgrep on config/ dir with orgmode expression
;; rg:orgmode:config/#org : run ripgrep on config/ dir with orgmode expression

;;; Code:

(require 'rg)
(require 'ol)

;; Install the link type
(org-link-set-parameters "rg"
                         :follow #'org-rg-follow-link
                         :face '(:foreground "DarkGreen" :underline t))

(defun org-rg-follow-link (regexp)
  "Run `rg` with REXEP as argument,
like this : [[rg:REGEXP:FOLDER#FILTER]]"
  (setq expressions (split-string regexp ":"))
  (setq exp (nth 0 expressions))
  (setq folderpart (nth 1 expressions))
  (setq files (split-string folderpart "#"))
  (setq folder (nth 0 files))
  (setq filter (nth 1 files))
  (if folderpart
      (if filter
          (rg exp (concat "*." filter) folder)
        (rg exp "*" folder))
    (rg exp "*" "./")))

(provide 'ol-rg)
;;; ol-rg.el ends here
