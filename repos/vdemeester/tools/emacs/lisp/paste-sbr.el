;;; paste-sbr.el --- Paste to sbr.pm -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Vincent Demeester

;; Author: Vincent Demeester <vincent@sbr.pm>
;; Keywords: org link github
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

;; Take selection and share it to paste.sbr.pm

;;; Code:

(defvar htmlize-paste-it-target-directory
  "desktop/sites/paste.sbr.pm")
(defvar htmlize-paste-it-base-url
  "https://paste.sbr.pm/")

(defun htmlize-paste-it ()
  "Htmlize region-or-buffer and copy to directory."
  (interactive)
  (let* ((start (if (region-active-p)
                    (region-beginning) (point-min)))
         (end (if (region-active-p)
                  (region-end) (point-max)))

         ;; We use a basename-hash.ext.html format
         (basename (file-name-base (buffer-name)))
         (extension (file-name-extension (buffer-name)))
         (hash (sha1 (current-buffer) start end))
         (file-name (concat basename
                            "-" (substring hash 0 6)
                            "." extension
                            ".html"))

         (new-file (expand-file-name (concat
                                      htmlize-paste-it-target-directory
                                      "/"
                                      file-name) "~"))

         (access-url (concat
                      htmlize-paste-it-base-url
                      file-name)))
    ;; Region messes with clipboard, so deactivate it
    (deactivate-mark)
    (with-current-buffer (htmlize-region start end)
      ;; Copy htmlized contents to target
      (write-file new-file)
      ;; Ensure target can be accessed by web server
      (chmod new-file #o755))
    ;; Put URL into clipboard
    (kill-new access-url)))

(provide 'paste-sbr)
;;; paste-sbr.el ends here
