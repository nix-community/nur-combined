;;; org-extra-emphasis.el --- Extra Emphasis markers for Org -*- lexical-binding: t; coding: utf-8-emacs; -*-

;; Copyright (C) 2022 Jambunathan K <kjambunathan at gmail dot com>
;; Copyright (C) 2004-2022 Free Software Foundation, Inc.

;; Author: Jambunathan K <kjambunathan at gmail dot com>
;; Keywords: org
;; Homepage: https://github.com/kjambunathan/org-extra-emphasis
;; Version: 1.0
;; Package-Requires: ((ox-odt "9.5.3.467"))

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Overview
;; ========
;;
;; This library provides two additional markers `!!' and `!@' over
;; and above those in `org-emphasis-alist'.'
;;
;; - Text enclosed in `!!' is highlighted in yellow, and exported likewise
;; - Text enclosed in `!@' is displayed in red, and exported likewise
;;
;; Following backends are supported: HTML and ODT. For export of extra
;; emphasis markers to the ODT side, you need
;; [[https://github.com/kjambunathan/org-mode-ox-odt][Enhanced ODT]]
;; exporter with version >= 9.5.3.467 (dtd. June 14, 2022 IST).  This
;; is the first version of the exporter that defines the user option
;; `org-odt-extra-styles'.
;;
;; Example
;; =======
;;
;; Setup
;; =====
;;
;; Add the following to your `user-init-file' and restart Emacs.
;;
;;    (requrie 'org-extra-emphasis)
;;
;; Test Run
;; ========
;;
;; 1. Create an `org' file, say `org-export-emphasis.org' and fill it
;;    with following content or you can download the file from
;;    https://raw.githubusercontent.com/kjambunathan/org-extra-emphasis/main/org-extra-emphasis.org

	  ;; #+TITLE: Test file for ==org-extra-emphasis== library

	  ;; * Demo of extra emphasis markers ==!!== and ==!@==

	  ;; !!Ea consectetur laboris adipiscing et ipsum labore esse qui minim
	  ;; pariatur et sunt sunt nostrud anim laborum culpa.!!

	  ;; !@Minim reprehenderit excepteur elit, dolore elit, veniam, eu.
	  ;; Ullamco dolore elit, cupidatat sed labore ea aute.!@

	  ;; Pariatur !!et lorem cupidatat !@minim irure!@ proident, ad.!!  Eiusmod
	  ;; sunt et lorem labore ex aliqua aute esse.

	  ;; Ut mollit !@duis velit est est magna in quis ipsum.  !!Aliqua aliqua
	  ;; non laboris exercitation cupidatat aliqua incididunt.!!  Qui voluptate
	  ;; irure aute occaecat laborum cillum est.!@  Quis magna dolor ullamco
	  ;; magna do consectetur est laborum enim ut.

	  ;; * !!Demo of extra emphasis markers in a styled paragraph!!

	  ;; #+ATTR_ODT: :target "extra_styles"
	  ;; #+begin_src nxml
	  ;; <style:style style:name="Warn"
	  ;;	     style:parent-style-name="Text_20_body"
	  ;;	     style:family="paragraph">
	  ;;   <style:paragraph-properties>
	  ;;     <style:tab-stops />
	  ;;   </style:paragraph-properties>
	  ;;   <style:text-properties fo:background-color="#ff0000"
	  ;;		       fo:color="#ffffff"
	  ;;		       fo:font-size="20pt"
	  ;;		       fo:font-style="italic"
	  ;;		       fo:font-weight="bold" />
	  ;; </style:style>
	  ;; #+end_src

	  ;; #+ATTR_ODT: :style "Warn"
	  ;; Proident, duis dolore consectetur sed nisi ea pariatur.  Esse
	  ;; proident, cillum duis qui ullamco sint cillum magna.  !!Eiusmod
	  ;; veniam, !@sint officia!@ non consectetur laboris cillum.!!  Cillum
	  ;; mollit consequat eu dolore ullamco qui reprehenderit anim cillum
	  ;; in consectetur consequat sunt dolore aliquip voluptate
	  ;; consectetur anim ea.  Voluptate nisi est incididunt aliquip
	  ;; excepteur aliqua id do enim ut non consequat.
;;
;; 2. Note that portions of text marked with `!!' and `!@' are fontified as described above.
;;
;; 3. Export the file to HTML with `C-c C-e h O'.
;;
;;    Note that the text enclosed in the above emphasis markers are
;;    colorized in HTML file.
;;
;; 4. Export the file to ODT with `C-c C-e o O'.
;;
;;    Note that the text enclosed in the above emphasis markers are
;;    colorized in ODT file.
;;
;; The HTML, ODT, PDF generated in steps (3) and (4) above are
;; available at https://github.com/kjambunathan/org-extra-emphasis and
;; the screenshots can be seen in https://github.com/kjambunathan/org-extra-emphasis/tree/main/screenshots
;;

;; Default Settings
;; ================
;;
;; 16 Emphasis Markers
;; ===================
;;
;; This library defines the following 16 emphasis markers,
;;
;; |----+----+----+----|
;; | !! | !@ | !% | !& |
;; |----+----+----+----|
;; | @! | @@ | @% | @& |
;; |----+----+----+----|
;; | %! | %@ | %% | %& |
;; |----+----+----+----|
;; | &! | &@ | &% | && |
;; |----+----+----+----|
;;
;; The above markers are all pairings of the following four characters:
;;     ! @ % &
;;
;; It is hoped that these set of emphasis markers don't pose issues
;; while exporting.
;;
;; 17 Extra Emphasis Faces
;; =======================
;;
;; This library defines 17 faces:
;;
;; - one base face `org-extra-emphasis'
;; - 16 more faces `org-extra-emphasis-01',`org-extra-emphasis-02',
;;  ..., `org-extra-emphasis-16'.
;;
;; The later 16 faces derive from `org-extra-emphasis' face.  Of
;; these, only the first two faces `org-extra-emphasis-01' and
;; `org-extra-emphasis-02' are explicitly configured.  If you are
;; using more than 2 emphasis markers, you may want to configure the
;; other 14 faces.
;;
;; `org-extra-emphasis-alist' already associated 16 emphasis markers
;; with 16 different faces.
;;
;; Customization
;; =============
;;
;; Configuring your own Emphasis Markers
;; =====================================
;;
;; 16 numbers of emphasis markers should suffice in practice.
;; However, if none of the above emphasis markers resonate with you,
;; you can customize `org-extra-emphasis-alist', and plug in your own
;; markers.  When choosing your own marker, ensure that you exercise
;; some care.  For example, if you choose `#' as a marker you are
;; likely to get malformed `html' and `odt' files.
;;
;; Configuring Extra Emphasis Faces
;; ===============================
;;
;; You can use `M-x customize-group RET org-extra-emphasis-faces RET'
;; to configure the extra emphasis faces.
;;
;; Disabling the Extra Emphasis
;; =============================
;;
;; You can use `M-x org-extra-emphasis-mode' to toggle this feature.
;;
;; Adding additional export backends
;; =================================
;;
;; To add additional backends, modify `org-extra-emphasis-formatter'
;; and `org-extra-emphasis-build-backend-regexp'.

;;; Code:

(require 'org)
(require 'ox-odt)
(require 'rx)
(require 'htmlfontify)

;;; PART-1: `org-extra-emphasis-mode'

;;;; Internal Variables

(defvar org-extra-emphasis-backends
  '(html odt ods))

(defvar org-extra-emphasis-info
  (list :enabled nil))

;; Helper snippets to convert a Emacs Face to Inine CSS and ODT Text Properties
;;
;; (defun org-extra-emphasis-emacs-face->inline-css (face)
;;   (let ((s (cdr (hfy-face-to-css-default face))))
;;     (when (string-match (rx-to-string '(and "{" (group (zero-or-more any)) "}")) s)
;;       (format "<span style=\"%s\">%%s</span>" (match-string 1 s)))))
;;
;; (org-extra-emphasis-emacs-face->inline-css 'hi-yellow)
;; (org-extra-emphasis-emacs-face->inline-css 'hi-red-b)
;;
;; (defun org-extra-emphasis-emacs-face->odt-text-properties (face)
;;   (org-odt--lisp-to-xml
;;    (assoc 'style:text-properties
;;	  (org-odt--xml-to-lisp
;;	   (cdr (org-odt-hfy-face-to-css face))))))
;;
;; (org-extra-emphasis-emacs-face->odt-text-properties 'hi-yellow)
;; (org-extra-emphasis-emacs-face->odt-text-properties 'hi-red-b)

(defun org-extra-emphasis-update (&rest _ignored)
  "Workhorse function that responds to configuration changes.

Current state is maintined in `org-extra-emphasis-info', a plist."
  ;; When `org-extra-emaphasis' is ON, override use
  ;; `org-extra-emphasis-org-do-emphasis-faces'.
  ;; Otherwise, use `org-do-emphasis-faces'.
  (cond
   ((plist-get org-extra-emphasis-info :enabled)
    (advice-add 'org-do-emphasis-faces :override
		'org-extra-emphasis-org-do-emphasis-faces))
   (t
    (advice-remove 'org-do-emphasis-faces
		   'org-extra-emphasis-org-do-emphasis-faces)))
  ;; `org-extra-emphasis-alist' is effective only if
  ;; `org-extra-emphasis' is enabled.
  (plist-put org-extra-emphasis-info :work-alist
	     (when (plist-get org-extra-emphasis-info :enabled)
	       (plist-get org-extra-emphasis-info :alist)))
  ;; Set properties that control fontification.
  ;; The property names and their values mimics the corresponding
  ;; variables in `org-set-emph-re'.
  (plist-put org-extra-emphasis-info :org-emphasis-alist
	     (when (and (boundp 'org-emphasis-regexp-components)
			org-emphasis-alist org-emphasis-regexp-components)
	       (append (plist-get org-extra-emphasis-info :work-alist)
		       org-emphasis-alist)))
  (plist-put org-extra-emphasis-info :org-emph-re-template
	     (when (and (boundp 'org-emphasis-regexp-components)
			org-emphasis-alist org-emphasis-regexp-components)
	       (pcase-let*
		   ((`(,pre ,post ,border ,body ,nl) org-emphasis-regexp-components)
		    (body (if (<= nl 0) body
			    (format "%s*?\\(?:\n%s*?\\)\\{0,%d\\}" body body nl))))
		 (format (concat "\\([%s]\\|^\\)" ;before markers
				 "\\(\\(%%s\\)\\([^%s]\\|[^%s]%s[^%s]\\)\\3\\)"
				 "\\([%s]\\|$\\)") ;after markers
			 pre border border body border post))))
  (plist-put org-extra-emphasis-info :org-emph-re
	     (format (plist-get org-extra-emphasis-info :org-emph-re-template)
		     (rx-to-string
		      `(or ,@(mapcar #'car
				     (cl-remove-if (lambda (l)
						     (eq 'verbatim (nth 2 l)))
						   (plist-get org-extra-emphasis-info :org-emphasis-alist)))))))
  (plist-put org-extra-emphasis-info :org-verbatim-re
	     (format (plist-get org-extra-emphasis-info :org-emph-re-template)
		     (rx-to-string
		      `(or ,@(mapcar #'car
				     (cl-remove-if-not (lambda (l)
							 (eq 'verbatim (nth 2 l)))
						       (plist-get org-extra-emphasis-info :org-emphasis-alist)))))
		     (rx-to-string
		      `(or ,@(mapcar #'car
				     (cl-remove-if-not (lambda (l)
							 (eq 'verbatim (nth 2 l)))
						       (plist-get org-extra-emphasis-info :org-emphasis-alist)))))))
  ;; Set properties that control Export backends
  ;; - Regexp to search for in the final exported document
  (plist-put org-extra-emphasis-info :export-alist
	     (org-extra-emphasis-build-backend-regexp))

  ;; - Generate ODT character styles for the extra emphasis faces and
  ;;   dump those in `org-odt-extra-styles' and `org-ods-automatic-styles'.
  (plist-put org-extra-emphasis-info :odt-extra-styles
	     (let* ((odt-styles
		     (concat (mapconcat #'identity
					(cl-loop for (_marker face) in (plist-get org-extra-emphasis-info :alist)
						 collect (cdr (org-odt-hfy-face-to-css face)))
					"\n\n"))))
	       (with-no-warnings
		 (unless (boundp 'org-odt-extra-styles)
		   (message "`org-odt-extra-styles' not found.  Upgrade to `ox-odt-9.5.3.467' or later.")
		   ;; (sleep-for 2)
		   (setq org-odt-extra-styles nil))
		 (setq org-odt-extra-styles
		       (concat (or (when (boundp 'org-odt-extra-styles)
				     (get 'org-odt-extra-styles 'saved-value))
				   "")
			       "\n\n"
			       odt-styles))
		 (setq org-ods-automatic-styles
		       (concat (or (when (boundp 'org-ods-automatic-styles)
				     (get 'org-ods-automatic-styles 'saved-value))
				   "")
			       "\n\n"
			       odt-styles))
		 (message "`org-odt-extra-styles' and `org-ods-automatic-styles' is updated for this session")
		 ;; (sleep-for 1)
		 )
	       odt-styles))
  ;; Re-fontify all Org buffers based on current configuration.
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'org-mode)
	(font-lock-flush)))))

;;;; Fontify Extra Emphasis Markers

(defun org-extra-emphasis-org-do-emphasis-faces (limit)
  "Workhorse function that does fontification This function is
based on `org-do-emphasis-faces'.  The property names and values
correspond to the variables used in `org-do-emphasis-faces'.  Key
differences are:

    - `:org-emphasis-alist' includes entries for both standard
      emphasis markers and extra emphasis markers.

    - The regexes used for search-based fontification allow for
      the possibility that the emphasis markers _in all
      likelihood_ are multi-char strings, as opposed to single
      chars."
  (let* ((quick-re (format "\\([%s]\\|^\\)\\(%s\\)"
			   (car org-emphasis-regexp-components)
			   (rx-to-string
			    `(or ,@(mapcar #'car (plist-get org-extra-emphasis-info :org-emphasis-alist)))))))
    (catch :exit
      (while (re-search-forward quick-re limit t)
	(let* ((marker (match-string 2))
	       (verbatim? (member marker '("~" "="))))
	  (when (save-excursion
		  (goto-char (match-beginning 0))
		  (and
		   ;; Do not match table hlines.
		   (not (and (equal marker "+")
			     (org-match-line
			      "[ \t]*\\(|[-+]+|?\\|\\+[-+]+\\+\\)[ \t]*$")))
		   ;; Do not match headline stars.  Do not consider
		   ;; stars of a headline as closing marker for bold
		   ;; markup either.
		   (not (and (equal marker "*")
			     (save-excursion
			       (forward-char)
			       (skip-chars-backward "*")
			       (looking-at-p org-outline-regexp-bol))))
		   ;; Match full emphasis markup regexp.
		   (looking-at (if verbatim? (plist-get org-extra-emphasis-info :org-verbatim-re)
				 (plist-get org-extra-emphasis-info :org-emph-re)))
		   ;; Do not span over paragraph boundaries.
		   (not (string-match-p org-element-paragraph-separate
					(match-string 2)))
		   ;; Do not span over cells in table rows.
		   (not (and (save-match-data (org-match-line "[ \t]*|"))
			     (string-match-p "|" (match-string 4))))))
	    (pcase-let ((`(,_ ,face ,_) (assoc marker (plist-get org-extra-emphasis-info :org-emphasis-alist)))
			(m (if org-hide-emphasis-markers 4 2)))
	      (font-lock-prepend-text-property
	       (match-beginning m) (match-end m) 'face face)
	      (when verbatim?
		(org-remove-flyspell-overlays-in
		 (match-beginning 0) (match-end 0))
		(remove-text-properties (match-beginning 2) (match-end 2)
					'(display t invisible t intangible t)))
	      (add-text-properties (match-beginning 2) (match-end 2)
				   '(font-lock-multiline t org-emphasis t))
	      (when (and org-hide-emphasis-markers
			 (not (org-at-comment-p)))
		(add-text-properties (match-end 4) (match-beginning 5)
				     '(invisible t))
		(add-text-properties (match-beginning 3) (match-end 3)
				     '(invisible t)))
	      (throw :exit t))))))))

;; There is no `:set' function for `deffaces'.  So, when the extra
;; faces `org-extra-emphasis-01', `org-extra-emphasis-02' reconfigured,
;; we don't get a notification.  The following export hook ensures
;; that `org-extra-emphasis-info' is in sync with user configuration.
(add-hook 'org-export-before-processing-hook 'org-extra-emphasis-update)

;;;; Export Extra Emphasis Markers

(defun org-extra-emphasis-formatter (marker text backend)
  "Style TEXT in the same font face as the face MARKER is mapped to.
Note that TEXT is in BACKEND format.

This currently supports HTML and ODT backends.

See `org-extra-emphasis-alist' for MARKER to face mappings."
  (let* ((face (car (assoc-default marker (plist-get org-extra-emphasis-info :work-alist))))
         (encode-attribute-value
	  (lambda (text)
	    (dolist (pair '(("&" . "&amp;")
			    ("<" . "&lt;")
			    (">" . "&gt;")
			    ("'" . "&apos;")
			    ("\"" . "&quot;")))
	      (setq text (replace-regexp-in-string (car pair) (cdr pair) text t t)))
	    text)))
    (cl-case backend
      ((odt ods)
       (format "<text:span text:style-name=\"%s\">%s</text:span>"
	       (car (org-odt-hfy-face-to-css face)) text))
      (html
       (format "<span class=\"%s\" style=\"%s\">%s</span>"
	       face
	       ;; An alternate implementation of
	       ;; `hfy-face-to-css-default' which performs correctly
	       ;; when a face specifies a `:family', and/or inherits
	       ;; some attributes from other faces.  Note that the
	       ;; flattening (or non-duplication) of face attributes
	       ;; here is done by Emacs itself.
	       (mapconcat (lambda (x)
			    (when (cdr x)
			      (format "%s: %s;" (car x)
                                      (funcall encode-attribute-value (cdr x)))))
			  (hfy-face-to-style-i
			   (cl-loop with props = (mapcar #'car face-attribute-name-alist)
				    for prop in props
				    for value = (face-attribute face prop nil 'default)
				    unless (eq prop :inherit)
				    append (list prop value)))
			  " ")
	       text))
      (_ text))))

(defun org-extra-emphasis-build-backend-regexp ()
  "Regexp to search for emphasized text in exported file.
This function transcode an emphasis MARKER which is in plain text
format, to the BACKEND format.  That is, if you use `<<' as an
emphasis marker, you need to search for `&lt;&lt;' in the
exported HTML file.

See `org-extra-emphasis-alist' for more information"
  (cl-loop for (marker . spec) in (plist-get org-extra-emphasis-info :work-alist) collect
	   (cons marker
		 (cl-loop for backend in org-extra-emphasis-backends collect
			  (cons backend
				(rx-to-string `(and ,(org-export-data-with-backend marker backend nil)
						    (group (minimal-match
							    (zero-or-more (or any "\n"))))
						    ,(org-export-data-with-backend marker backend nil))))))))

(defun org-extra-emphasis-plain-text-filter (text backend _info)
  "Transcode TEXT in to BACKEND format.
Uses `org-extra-emphasis-formatter' to do the transcoding.

Search TEXT for one or more transcoded MARKERs, and mark it up as
specified in `org-extra-emphasis-alist'."
  (with-temp-buffer
    (insert text)
    (cl-loop for (marker . spec) in (plist-get org-extra-emphasis-info :export-alist)
	     for regex = (assoc-default backend spec)
	     do (goto-char (point-min))
	     (if (not regex) text
	       (while (re-search-forward regex nil t)
		 (let* ((contents (match-string 1))
			(emphasized-contents (save-match-data
					       (org-extra-emphasis-formatter
						marker contents backend))))
		   (replace-match emphasized-contents t t)))))
    (buffer-substring-no-properties (point-min) (point-max))))

;; Install export filter for transcoding extra emphasis markers.
(defun org-extra-emphasis-update-filter-functions (&optional export-filter-functions)
  (let* ((all-filter-functions (thread-last org-export-filters-alist
					    (seq-map #'cdr)
					    (seq-sort #'string<))))
    (dolist (filter-fn '(org-extra-emphasis-plain-text-filter org-extra-emphasis-strip-zws-maybe))
      (dolist (it all-filter-functions)
        (set it (delq filter-fn (symbol-value it))))
      (dolist (it export-filter-functions)
        (add-to-list it filter-fn)))))

;;;; User Options & Commands

;;;;; Custom Groups

(defgroup org-extra-emphasis nil
  "Options for highlighting and exporting extra emphasis markers in Org files."
  :tag "Org Extra Emphasis"
  :group 'org)

(defgroup org-extra-emphasis-faces nil
  "Faces for Org Extra Emphasis."
  :group 'org-extra-emphasis
  :group 'faces)

;;;; Custom Faces

(defface org-extra-emphasis nil
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-01
  '((t (:inherit org-extra-emphasis :background "yellow")))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-02
  '((t (:inherit org-extra-emphasis :foreground "red")))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-03
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-04
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-05
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-06
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-07
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-08
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-09
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-10
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-11
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-12
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-13
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-14
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-15
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

(defface org-extra-emphasis-16
  '((t (:inherit org-extra-emphasis)))
  "A face for Org Extra Emphasis."
  :group 'org-extra-emphasis-faces)

;;;;; Useful Org Setting

(setcar (last org-emphasis-regexp-components) 5)

(defcustom org-extra-emphasis-alist
  '(("!!" org-extra-emphasis-01)
    ("!@" org-extra-emphasis-02)
    ("!%" org-extra-emphasis-03)
    ("!&" org-extra-emphasis-04)
    ("@!" org-extra-emphasis-05)
    ("@@" org-extra-emphasis-06)
    ("@%" org-extra-emphasis-07)
    ("@&" org-extra-emphasis-08)
    ("%!" org-extra-emphasis-09)
    ("%@" org-extra-emphasis-10)
    ("%%" org-extra-emphasis-11)
    ("%&" org-extra-emphasis-12)
    ("&!" org-extra-emphasis-13)
    ("&@" org-extra-emphasis-14)
    ("&%" org-extra-emphasis-15)
    ("&&" org-extra-emphasis-16))
  "Alist of emphasis marker and its associated face."
  :group 'org-extra-emphasis
  :type '(repeat
	  (list
	   (string :tag "Emphasis Marker")
	   (face :tag "Face")))
  :set (lambda (var val)
	 (set var val)
	 (plist-put org-extra-emphasis-info :alist val)
	 (org-extra-emphasis-update)))

(defcustom org-extra-emphasis t
  "When non-nil, enable Org Extra Emphasis."
  :group 'org-extra-emphasis
  :type '(boolean "Org Extra Emphasis")
  :set (lambda (var val)
	 (set var val)
	 (plist-put org-extra-emphasis-info :enabled val)
	 (org-extra-emphasis-update)))

(defcustom org-extra-emphasis-filter-functions
  '(
    org-export-filter-headline-functions
    org-export-filter-paragraph-functions
    org-export-filter-table-cell-functions
    )
  "List of places to which `org-extra-emphasis-plain-text-filter'
and `org-extra-emphasis-strip-zws-maybe' hooks itself.

The places should be one among the values that occur in
`org-export-filters-alist'.

By default, the list includes
    - `org-export-filter-headline-functions'
    - `org-export-filter-paragraph-functions'
    - `org-export-filter-table-cell-functions',

This means that text with extra emphasis which appears as plain
text, or within headlines and table cells will be, fontified."
  :group 'org-extra-emphasis
  :type `(set
          ,@(thread-last org-export-filters-alist
			 (seq-map #'cdr)
                         (seq-sort #'string<)
			 (seq-map (lambda (it)
			            (list 'const it)))))
  :set (lambda (var value)
         (set-default var value)
         (org-extra-emphasis-update-filter-functions value)))

;;;;; `M-x org-extra-emphasis-mode'

(defun org-extra-emphasis-mode (&optional arg)
  "Enable / Disable Org Extra Emphasis.

If called interactively, toggle Extra Emphasis.

When called non-interactively, enable Extra Emphasis if ARG is
positive; disable otherwise."
  (interactive "p")
  (cond
   ;; Called interactively; Toggle
   ((called-interactively-p 'any)
    (setq org-extra-emphasis (not org-extra-emphasis)))
   ;; Called programatically; enable if arg >= 1
   ((and (numberp arg)
	 (>= arg 1))
    (setq org-extra-emphasis t))
   ;; Otherwise, disable
   (t
    (setq org-extra-emphasis nil)))
  (plist-put org-extra-emphasis-info :enabled org-extra-emphasis)
  (org-extra-emphasis-update))

;;; PART-2: `org-extra-emphasis-intraword-emphasis-mode'

;;;; User options

(defface org-extra-emphasis-zws-face
  '((t (:inherit org-extra-emphasis :foreground "red")))
  "Use this face to highlight the ZERO WIDTH SPACE character."
  :group 'org-extra-emphasis-faces)

(defcustom org-extra-emphasis-zws-display-char ?\N{SPACING UNDERSCORE}
  "Use the glyph of this character to display ZERO WIDTH SPACE.

Set this to nil, if you want the ZERO WIDTH SPACE to remain
inconspicuous in the buffer.  Note that even if ZERO WIDTH SPACE
is inconspicuos in the buffer, the ZERO WIDTH SPACE will be
stripped from the export output accoding to the value of
`org-extra-emphasis-intraword-emphasis-mode'."
  :type '(choice (const :tag "Disabled" nil)
		 (character :tag "Display ZERO WIDTH SPACE as "))
  :group 'org-extra-emphasis)

;;;; Internal Variables

(defvar-local org-extra-emphasis-stashed-display-table nil
  "Stashed value of `buffer-display-table'.

This is the value of `buffer-display-table' before
`org-extra-emphasis-intraword-emphasis-mode' is turned on in the
buffer.

Use this value to restore a buffer's `buffer-display-table' when
`org-extra-emphasis-intraword-emphasis-mode' is turned off in the
buffer.")

;;;;  `M-x org-extra-emphasis-intraword-emphasis-mode'

;;;###autoload
(define-minor-mode org-extra-emphasis-intraword-emphasis-mode
  "Toggle intra word emphasis in `org-mode' export.

When `org-extra-emphasis-intraword-emphasis-mode' is enabled:

- ZERO WIDTH SPACE characters are stripped from export backends.
- ZERO WIDTH SPACE characters are displayed using
  `org-extra-emphasis-zws-display-char' and highlighted with
  `org-extra-emphasis-zws-face' space.

TIPS for the user:

1. You can insert ZERO WIDTH SPACE using

       `M-x insert-char RET ZERO WIDTH SPACE RET'

   One another way is to store that the ZERO WIDTH SPACE in a
   register, say SPC, and

       (set-register ?\N{SPACE} \"\N{ZERO WIDTH SPACE}\")
       
   and use the \\[insert-register] command on that register to insert
   the ZERO WIDTH SPACE character.

2. You can examine the presence of ZERO WIDTH SPACE character in the
   export output by turning on the `glyphless-display-mode'."
  :lighter " ZWS"
  :init-value nil
  :global t
  :group 'org-extra-emphasis
  (cond
   ;; Turn ON `org-extra-emphasis-intraword-emphasis-mode'
   (org-extra-emphasis-intraword-emphasis-mode
    (when org-extra-emphasis-zws-display-char
	    ;; Display ZERO WIDTH CHAR in a conspicuous way.
	    (setq org-extra-emphasis-stashed-display-table (copy-sequence buffer-display-table))
	    (unless buffer-display-table
	      (setq buffer-display-table (make-display-table)))
	    (aset buffer-display-table
		  ?\N{ZERO WIDTH SPACE}
		  (vector (make-glyph-code org-extra-emphasis-zws-display-char
					   'org-extra-emphasis-zws-face)))))
   (t
    ;; Turn OFF `org-extra-emphasis-intraword-emphasis-mode'
    (when org-extra-emphasis-zws-display-char
      ;; Restore the buffer's original `buffer-display-table'.
      (setq buffer-display-table org-extra-emphasis-stashed-display-table)))))

;; Adjust `buffer-display-table' so that ZERO WIDTH SPACE characters
;; are displayed.
(add-hook 'org-mode-hook 'org-extra-emphasis-intraword-emphasis-mode t)

;;;; Export hook to strip ZERO WIDTH SPACE

(defun org-extra-emphasis-strip-zws-maybe (text _backend _info)
  "Strip ZERO WIDTH SPACE from TEXT.

If `org-extra-emphasis-intraword-emphasis-mode' is enabled, strip
ZERO WIDTH SPACE from TEXT.  Otherwise, return TEXT unmodified."
  (cond
   ;; `org-extra-emphasis-intraword-emphasis-mode' is ON
   (org-extra-emphasis-intraword-emphasis-mode
    ;; Strip ZERO WIDTH SPACE.
    (replace-regexp-in-string
     (rx-to-string `(one-or-more ,(char-to-string ?\N{ZERO WIDTH SPACE})))
     "" text t t))
   ;; `org-extra-emphasis-intraword-emphasis-mode' is OFF.
   (t
    ;; Nothing to do.
    text)))

;; Configure Org Export Engine to strip ZERO WIDTH SPACE, if needed.
;; (dolist (it '(org-export-filter-table-cell-functions
;; 	      org-export-filter-paragraph-functions))
;;   (add-to-list it 'org-extra-emphasis-strip-zws-maybe it))

(provide 'org-extra-emphasis)

;;; org-extra-emphasis.el ends here
