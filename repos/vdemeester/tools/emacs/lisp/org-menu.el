;;; org-menu.el --- A discoverable menu for org-mode using transient -*- lexical-binding: t; coding: utf-8 -*-
;;
;; Copyright 2021 Jan Rehders
;;
;; Author: Jan Rehders <nospam@sheijk.net>
;; Version: 0.1alpha
;; Package-Requires: ((emacs "26.1") (transient "0.1"))
;; URL: https://github.com/sheijk/org-menu
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;; Commentary:
;;
;; Usage:
;;
;; Add this to your ~/.emacs to bind the menu to `C-c m':
;;
;; (with-eval-after-load 'org
;;   (require 'org-menu) ;; not needed if installing by package manager
;;   (define-key org-mode-map (kbd "C-c m") 'org-menu))
;;
;; The menu should be pretty self-explanatory.  It is context dependent and
;; offers different commands for headlines, tables, timestamps, etc.
;; The task menu provides entry points for task that work from anywhere.
;;
;;; Code:

(require 'org)
(require 'transient)

(defgroup org-menu nil
  "Options for org-menu"
  :group 'org)

(defcustom org-menu-use-q-for-quit t
  "Whether to add a q binding to quit to all menus.

Use this if you prefer to be consistent with magit.  It will also
change some other bindings to use Q instead of q."
  :group 'org-menu
  :type 'boolean)

(defcustom org-menu-global-toc-depth 10
  "The number of heading levels to show when displaying the global content."
  :group 'org-menu
  :type 'integer)

(defun org-menu-heading-navigate-items (check-for-heading &optional cycle-function)
  "Items to navigate headings.

These will be added to most sub menus.  If `CHECK-FOR-HEADING' is
true the items will only be added if on a heading.  `CYCLE-FUNCTION' is the
function to be used to cycle visibility of current element."
  (setq cycle-function (or cycle-function #'org-cycle))
  `(["Navigate"
     ,@(when check-for-heading '(:if org-at-heading-p))
     ("p" "prev" org-previous-visible-heading :transient t)
     ("n" "next" org-next-visible-heading :transient t)
     ("c" "cycle" ,cycle-function :transient t)
     ("u" "parent" outline-up-heading :transient t)
     ("M-p" "prev (same level)" org-backward-heading-same-level :transient t)
     ("M-n" "next (same level)" org-forward-heading-same-level :transient t)
     ("M-w" "store link" org-store-link :transient t :if-not region-active-p)
     ("C-_" "undo" undo :transient t)]))

(defun org-menu-show-headline-content ()
  "Will show the complete content of the current headline and it's children."
  (interactive)
  (save-excursion
    (outline-hide-subtree)
    (org-show-children 4)
    (org-goto-first-child)
    (org-reveal '(4))))

;;;###autoload (autoload 'org-menu-visibility "org-menu" nil t)
(transient-define-prefix org-menu-visibility ()
  "A menu to control visibility of org-mode items"
  ["dummy"])

(transient-insert-suffix 'org-menu-visibility (list 0)
  `["Visibility"
    ,@(org-menu-heading-navigate-items nil)
    ["Visibility"
     ("a" "all" org-show-subtree :if-not org-at-block-p :transient t)
     ("a" "all" org-hide-block-toggle :if org-at-block-p :transient t)
     ("t" "content" org-menu-show-headline-content :if-not org-at-block-p :transient t)
     ("h" "hide" outline-hide-subtree :if-not org-at-block-p :transient t)
     ("h" "hide" org-hide-block-toggle :if org-at-block-p :transient t)
     ("r" "reveal" (lambda () (interactive) (org-reveal t)) :if-not org-at-block-p :transient t)]
    ["Global"
     ("C" "cycle global" org-global-cycle :transient t)
     ("go" "overview" org-overview)
     ("gt" "content" (lambda () (interactive) (org-content org-menu-global-toc-depth)))
     ("ga" "all" org-show-all)
     ("gd" "default" (lambda () (interactive) (org-set-startup-visibility)))]
    ["Quit"
     :if-non-nil org-menu-use-q-for-quit
     ("q" "quit" transient-quit-all)]])

(defun org-menu-eval-src-items ()
  "Return the items to evaluate a source block."
  (list
   ["Source"
    :if org-in-src-block-p
    ("e" "run block" org-babel-execute-src-block)
    ("c" "check headers" org-babel-check-src-block)
    ("k" "clear results" org-babel-remove-result-one-or-many)
    ("'" "edit" org-edit-special)]))

;;;###autoload (autoload 'org-menu-eval "org-menu" nil t)
(transient-define-prefix org-menu-eval ()
  "A menu to evaluate buffers, tables, etc. in org-mode"
  ["dummy"])

(defun org-menu-run-gnuplot ()
  "Will call `org-plot/gnuplot' and update inline images."
  (interactive)
  (org-plot/gnuplot)
  (when org-inline-image-overlays
    (org-redisplay-inline-images)))

(transient-insert-suffix 'org-menu-eval (list 0)
  `["Evaluation"
    ["Table"
     :if org-at-table-p
     ("e" "table" (lambda () (interactive) (org-table-recalculate 'iterate)))
     ("1" "one iteration" (lambda () (interactive) (org-table-recalculate t)))
     ("l" "line" (lambda () (interactive) (org-table-recalculate nil)))
     ("f" "format" org-table-align :if org-at-table-p)]
    ,@(org-menu-eval-src-items)
    ["Heading"
     :if-not org-in-src-block-p
     ("c" "update checkbox count" org-update-checkbox-count)]
    ["Plot"
     ("p" "gnuplot" org-menu-run-gnuplot)]
    ["Quit"
     :if-non-nil org-menu-use-q-for-quit
     ("q" "quit" transient-quit-all)]])

(defun org-menu-insert-block (str)
  "Insert an org mode block of type `STR'."
  (interactive)
  (insert (format "#+begin_%s\n#+end_%s\n" str str)))

(defun org-menu-expand-snippet (snippet)
  "Will expand the given snippet named `SNIPPET'."
  (interactive)
  (if (require 'yasnippet nil 'noerror)
      (progn
        (insert snippet)
        (yas-expand))
    (message "error: yasnippet not installed, could not expand %s" snippet)))

;;;###autoload (autoload 'org-menu-insert-blocks "org-menu" nil t)
(transient-define-prefix org-menu-insert-blocks ()
  "A menu to insert new blocks in org-mode"
  [["Insert block"
    ("s" "source" (lambda () (interactive) (org-menu-insert-block "src")))
    ("e" "example" (lambda () (interactive) (org-menu-insert-block "example")))
    ("v" "verbatim" (lambda () (interactive) (org-menu-insert-block "verbatim")))
    ("a" "ascii" (lambda () (interactive) (org-menu-insert-block "ascii")))
    ("q" "quote" (lambda () (interactive) (org-menu-insert-block "quote")) :if-nil org-menu-use-q-for-quit)
    ("Q" "quote" (lambda () (interactive) (org-menu-insert-block "quote")) :if-non-nil org-menu-use-q-for-quit)
    ("d" "dynamic block" org-dynamic-block-insert-dblock)]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

;;;###autoload (autoload 'org-menu-insert-heading "org-menu" nil t)
(transient-define-prefix org-menu-insert-heading ()
  "A menu to insert new headings in org-mode"
  [["Heading"
    ("h" "heading" org-insert-heading)
    ("H" "heading (after)" org-insert-heading-after-current)
    ("T" "todo" org-insert-todo-heading)]
   ["Items"
    ("d" "drawer" org-insert-drawer)]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

;;;###autoload (autoload 'org-menu-insert-template "org-menu" nil t)
(transient-define-prefix org-menu-insert-template ()
  "A menu to insert new templates in org-mode"
  [["Templates"
    ("S" "structure template" org-insert-structure-template)
    ("B" "yas blocks" (lambda () (interactive) (org-menu-expand-snippet "beg")))
    ("O" "yas options" (lambda () (interactive) (org-menu-expand-snippet "opt")))]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

;;;###autoload (autoload 'org-menu-insert-timestamp "org-menu" nil t)
(transient-define-prefix org-menu-insert-timestamp ()
  "A menu to insert timestamps in org-mode"
  [["Timestamp"
    ("." "active" org-time-stamp)
    ("!" "inactive" org-time-stamp-inactive)]
   ["Now"
    ("n" "active" (lambda () (interactive) (org-insert-time-stamp (current-time) t)))
    ("N" "inactive" (lambda () (interactive) (org-insert-time-stamp (current-time) t t)))]
   ["Today"
    ("t" "active" (lambda () (interactive) (org-insert-time-stamp (current-time) nil)))
    ("T" "inactive" (lambda () (interactive) (org-insert-time-stamp (current-time) nil t)))]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

(defun org-menu-table-insert-row-below ()
  "Insert a new table column below point."
  (interactive)
  (org-table-insert-row '4))

(defun org-menu-table-insert-column-left ()
  "Insert a new column to the left of point."
  (interactive)
  (org-table-insert-column)
  (org-table-move-column-right))

;;;###autoload (autoload 'org-menu-insert-table "org-menu" nil t)
(transient-define-prefix org-menu-insert-table ()
  "A menu to insert table items in org-mode"
  [["Table"
    ("t" "table" org-table-create-or-convert-from-region :if-not org-at-table-p)
    ("i" "import" org-table-import :if-not org-at-table-p)]
   ["Rows/columns"
    :if org-at-table-p
    ("r" "row above" org-table-insert-row :transient t)
    ("R" "row below" org-menu-table-insert-row-below :transient t)
    ("c" "column right" org-table-insert-column :transient t)
    ("C" "column left" org-menu-table-insert-column-left :transient t)
    ("-" "horiz. line" org-table-insert-hline :transient t)]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

(defun org-menu-insert-superscript ()
  "Insert a text with superscript."
  (interactive)
  (if (require 'yasnippet nil 'noerror)
      (yas-expand-snippet "${1:text}^{${2:super}}")
    (insert "a^b")))

(defun org-menu-insert-subscript ()
  "Insert a text with subscript."
  (interactive)
  (if (require 'yasnippet nil 'noerror)
      (yas-expand-snippet "${1:text}_{${2:sub}}")
    (insert "a_b")))

(defun org-menu-parse-formatting (format-char)
  "Will return the bounds of the format markup `FORMAT-CHAR'."
  (let ((original-point (point))
        start end)
    (ignore-errors
      (save-excursion
        (save-restriction
          (save-match-data
            (org-narrow-to-element)
            (goto-char (search-backward (format "%c" format-char)))
            (setq start (point))
            (goto-char original-point)
            (goto-char (search-forward (format "%c" format-char)))
            (setq end (point))
            (cons start end)))))))

(defun org-menu-toggle-format (format-char)
  "Will add/remove the given format wrapped in `FORMAT-CHAR' form the region (or point)."
  (let ((range (org-menu-parse-formatting format-char))
        (format-string (format "%c" format-char)))
    (if (null range)
        (org-menu-insert-text format-string format-string t)
      (goto-char (cdr range))
      (delete-backward-char 1)
      (goto-char (car range))
      (delete-char 1))))

;;;###autoload (autoload 'org-menu-insert-list "org-menu" nil t)
(transient-define-prefix org-menu-insert-list ()
  "A menu to insert lists"
  [["List"
    ("-" "item" (lambda () (interactive) (insert "- ")))
    ("+" "+" (lambda () (interactive) (insert "+ ")))
    ("*" "*" (lambda () (interactive) (insert "* ")))
    ("." "1." (lambda () (interactive) (insert "1. ")))
    (")" "1)" (lambda () (interactive) (insert "1) ")))]
   ["Todo"
    ("t" "todo" (lambda () (interactive) (insert "- [ ] ")))
    ("d" "done" (lambda () (interactive) (insert "- [X] ")))
    ("p" "partial" (lambda () (interactive) (insert "- [-] ")))]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

(defun org-menu-insert-plot ()
  "Insert a small example plot for `gnu-plot'."
  (interactive)
  (beginning-of-line 1)
  (if (require 'yasnippet nil 'noerror)
      (yas-expand-snippet
       "#+plot: type:${1:2d} file:\"${2:plot.svg}\"
| A |  B |
|---+----|
| 1 | 10 |
| 2 |  8 |
| 3 |  9 |

#+attr_org: :width ${3:400px}
[[file:$2]]
")
    (insert
     "#+plot: type:2d file:\"plot.svg\"
| A |  B |
|---+----|
| 1 | 10 |
| 2 |  8 |
| 3 |  9 |

#+attr_org: :width 400px
[[file:plot.svg]]
")))

;;;###autoload (autoload 'org-menu-insert "org-menu" nil t)
(transient-define-prefix org-menu-insert ()
  "A menu to insert new items in org-mode"
  [["Insert"
    ("." "time" org-menu-insert-timestamp)
    ("t" "table" org-menu-insert-table)
    ("h" "heading" org-menu-insert-heading)
    ("b" "block" org-menu-insert-blocks)
    ("T" "templates" org-menu-insert-template)
    ("l" "link (new)" org-insert-link)
    ("L" "link (stored)" org-insert-last-stored-link :transient t)
    ("-" "list" org-menu-insert-list)
    ("p" "plot" org-menu-insert-plot)]
   ["Format"
    ("^" "superscript" org-menu-insert-superscript)
    ("_" "subscript" org-menu-insert-subscript)]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

(defun org-menu-comment-line ()
  "Toggle line comment w/o moving cursor."
  (interactive)
  (save-excursion (comment-line 1)))

(defun org-menu-insert-text (left right &optional surround-whitespace)
  "Will insert left|right and put the curser at |.

If region is active it will be surrounded by `LEFT' and `RIGHT' and
the point will be at end of region.  Will add spaces before/after text if
`SURROUND-WHITESPACE' is true and it's needed."

  (let ((start (point))
        (end (point)))
    (when (region-active-p)
      (setq start (region-beginning)
            end (region-end))
      (deactivate-mark))
    (when (> start end)
      ;; swap variables w/o importing cl-lib
      (setq start (prog1 end (setq end start))))

    (goto-char start)
    (when (and surround-whitespace
               (not (bolp))
               (not (looking-back " +")))
      (insert " "))
    (insert left)

    (forward-char (- end start))

    (save-excursion
      (insert right)
      (when (and surround-whitespace
                 (not (eolp))
                 (not (looking-at " +")))
        (insert " ")))))

(defun org-menu-in-time-p ()
  "Return whether we're at a time stamp or similar.

Adapted from `org-goto-calendar'"
  (or (org-at-timestamp-p 'lax)
      (org-match-line (concat ".*" org-ts-regexp))))

;;;###autoload (autoload 'org-menu-goto "org-menu" nil t)
(transient-define-prefix org-menu-goto ()
  "Menu to go to different places by name"
  [["Go to"
    ("h" "heading" imenu)
    ("s" "source block" org-babel-goto-named-src-block)
    ("r" "result block" org-babel-goto-named-result)
    ("." "calendar" org-goto-calendar :if org-menu-in-time-p)]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

(defun org-menu-at-text-p ()
  "Return whether point is at text."
  (not (or (org-at-heading-p)
           (org-at-table-p)
           (org-in-item-p)
           (org-in-src-block-p))))

(defun org-menu-text-format-items (check-for-table)
  "Items to format text.

Will add an ':if org-menu-at-text-p' criteria if `CHECK-FOR-TABLE' is true."
  (list
   `["Navigate"
     ,@(when check-for-table '(:if org-menu-at-text-p))
     ("p" "up" previous-line :transient t)
     ("n" "down" next-line :transient t)
     ("b" "left" backward-word :transient t)
     ("f" "right" forward-word :transient t)
     ("u" "parent" org-up-element :transient t)
     ("M-w" "store link" org-store-link :transient t :if-not region-active-p)
     ("C-_" "undo" undo :transient t)
     ("SPC" "mark" set-mark-command :transient t)
     ("C-x C-x" "exchange" exchange-point-and-mark :transient t)]
   `["Formatting"
     ,@(when check-for-table '(:if org-menu-at-text-p))
     ("*" "Bold" (lambda nil (interactive) (org-menu-toggle-format ?*)) :transient t)
     ("/" "italic" (lambda nil (interactive) (org-menu-toggle-format ?/)) :transient t)
     ("_" "underline" (lambda nil (interactive) (org-menu-toggle-format ?_)) :transient t)
     ("+" "strikethrough" (lambda nil (interactive) (org-menu-toggle-format ?+)) :transient t)]
   `["Source"
     ,@(when check-for-table '(:if org-menu-at-text-p))
     ("~" "code" (lambda nil (interactive) (org-menu-toggle-format ?~)) :transient t)
     ("=" "verbatim" (lambda nil (interactive) (org-menu-toggle-format ?=)) :transient t)]))

;;;###autoload (autoload 'org-menu-text-in-element "org-menu" nil t)
(transient-define-prefix org-menu-text-in-element ()
  "Add formatting for text inside other elements like lists and tables"
  ["dummy"])

(transient-insert-suffix 'org-menu-text-in-element (list 0)
  `[,@(org-menu-text-format-items nil)
    ["Quit"
     :if-non-nil org-menu-use-q-for-quit
     ("q" "quit" transient-quit-all)]])

;;;###autoload (autoload 'org-menu-options "org-menu" nil t)
(transient-define-prefix org-menu-options ()
  "A menu to toggle options"
  [["Display"
    ("l" "show links" org-toggle-link-display)
    ("i" "inline images" org-toggle-inline-images)
    ("p" "pretty entities" org-toggle-pretty-entities)
    ("I" "indent by level" org-indent-mode)
    ("t" "timestamp overlay" org-toggle-time-stamp-overlays)
    ("n" "numbered headings" org-num-mode)]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

(defun org-menu-in-link ()
  "Return whether we are inside a link.

Conditions have been adapted from `org-insert-link'"
  (or
   ;; Use variable from org-compat to support Emacs 26
   (org-in-regexp org-bracket-link-regexp 1)
   (when (boundp 'org-link-angle-re)
     (org-in-regexp org-link-angle-re))
   (when (boundp 'org-link-plain-re)
     (org-in-regexp org-link-plain-re))))

(defun org-menu-toggle-has-checkbox ()
  "Toggle whether the current list item has a checkbox."
  (interactive)
  (save-excursion
    (back-to-indentation)
    (if (not (looking-at "- "))
        (message "Not at list item")
      (end-of-line 1)
      (org-ctrl-c-ctrl-c '(4)))))

(defun org-menu-is-timer-running ()
  "Return whether a timer is currently running."
  (and org-timer-start-time
       (not org-timer-countdown-timer)
       (not org-timer-pause-time)))

(defun org-menu-is-timer-paused ()
  "Return whether a timer has been started and is paused."
  (and org-timer-start-time
       (not org-timer-countdown-timer)
       org-timer-pause-time))

;;;###autoload (autoload 'org-menu-clock "org-menu" nil t)
(transient-define-prefix org-menu-clock ()
  "Time management using org-modes clock"
  [["Clock"
    ("<tab>" "in" org-clock-in :if-not org-clock-is-active)
    ("TAB" "in" org-clock-in :if-not org-clock-is-active)
    ("o" "out" org-clock-out :if org-clock-is-active)
    ("j" "goto" org-clock-goto :if org-clock-is-active)
    ("q" "cancel" org-clock-cancel
     :if (lambda () (and (not org-menu-use-q-for-quit)
                         (org-clock-is-active))))
    ("Q" "cancel" org-clock-cancel
     :if (lambda () (and org-menu-use-q-for-quit
                         (org-clock-is-active))))
    ("d" "display" org-clock-display :if org-clock-is-active)
    ("x" "in again" org-clock-in-last :if-not org-clock-is-active)
    ("z" "resolve" org-resolve-clocks)]
   ["Timer"
    ("0" "start" org-timer-start :if-nil org-timer-start-time)
    ("_" "stop" org-timer-stop :if-non-nil org-timer-start-time)
    ("." "insert" org-timer :if-non-nil org-timer-start-time)
    ("-" "... item" org-timer-item :if-non-nil org-timer-start-time)
    ("," "pause" org-timer-pause-or-continue :if org-menu-is-timer-running)
    ("," "continue" org-timer-pause-or-continue :if org-menu-is-timer-paused)
    (";" "countdown" org-timer-set-timer :if-nil org-timer-start-time)]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

(transient-define-prefix org-menu-search-and-filter ()
  "A menu to search and filter org-mode documents"
  ["Search and filter"
   ["Filter"
    ("/" "only matching" org-sparse-tree)
    ("q" "tags" org-tags-sparse-tree :if-nil org-menu-use-q-for-quit)
    ("Q" "tags" org-tags-sparse-tree :if-non-nil org-menu-use-q-for-quit)
    ("t" "todos" org-show-todo-tree)
    ("d" "deadlines" org-check-deadlines)
    ("b" "before date" org-check-before-date)
    ("a" "after date" org-check-after-date)
    ("D" "dates range" org-check-dates-range)]
   ["Agenda"
    ("A" "open" org-agenda)]
   ["Quit"
    :if-non-nil org-menu-use-q-for-quit
    ("q" "quit" transient-quit-all)]])

(transient-define-prefix org-menu-attachments ()
  "A menu to manage attachments"
  ["Attachments"
   ["Add"
    ("a" "file" org-attach-attach)
    ("c" "copy" org-attach-attach-cp)
    ("m" "move" org-attach-attach-mv)
    ("l" "link" org-attach-attach-ln)
    ("y" "symlink" org-attach-attach-lns)
    ("u" "download" org-attach-url)
    ("b" "buffer" org-attach-buffer)
    ("n" "new" org-attach-new)]
   ["Open"
    ("o" "attachment" org-attach-open)
    ("O" "in Emacs" org-attach-open-in-emacs)
    ("f" "directory" org-attach-reveal)
    ("F" "in Emacs" org-attach-reveal-in-emacs)]
   ["Delete"
    ("d" "delete" org-attach-delete-one)
    ("D" "all" org-attach-delete-all)]
   ["More"
    ("s" "set directory" org-attach-set-directory)
    ("S" "unset" org-attach-unset-directory)
    ("z" "synchronize" org-attach-sync)]])

(transient-define-prefix org-menu-archive ()
  "A menu to archive items"
  ["dummy"])

(transient-insert-suffix 'org-menu-archive (list 0)
  `["Archive"
    ,@(org-menu-heading-navigate-items nil #'org-force-cycle-archived)
    ["Archive to"
     ("t" "tree" org-archive-subtree :transient t)
     ("s" "sibling" org-archive-to-archive-sibling :transient t)
     ("Q" "tag" org-toggle-archive-tag :transient t)]])

(defun org-menu-insert-todo-heading-after-current ()
  "Insert a new todo heading with same level as current, after subtree."
  (interactive)
  (org-insert-todo-heading '(16)))

;;;###autoload (autoload 'org-menu "org-menu" nil t)
(transient-define-prefix org-menu ()
  "A discoverable menu to edit and view org-mode documents"
  ["dummy"])

(transient-insert-suffix 'org-menu (list 0)
  `["Org mode"
    ;; Items for headings
    ,@(org-menu-heading-navigate-items t)

    ["Move heading"
     :if org-at-heading-p
     ("P" "up" org-metaup :transient t)
     ("N" "down" org-metadown :transient t)
     ("B" "left" org-shiftmetaleft :transient t)
     ("F" "right" org-shiftmetaright :transient t)
     ("b" "left (line)" org-metaleft :transient t)
     ("f" "right (line)" org-metaright :transient t)
     ("r" "refile" org-refile :transient t)]
    ["Change heading"
     :if org-at-heading-p
     ("*" "toggle" org-ctrl-c-star :if-not org-at-table-p :transient t)
     ("t" "todo" org-todo :transient t)
     ("q" "tags" org-set-tags-command :transient t :if-nil org-menu-use-q-for-quit)
     ("Q" "tags" org-set-tags-command :transient t :if-non-nil org-menu-use-q-for-quit)
     ("y" "property" org-set-property :transient t)
     ("," "priority" org-priority :transient t)
     ("A" "archive" org-menu-archive :transient t)
     ("D" "deadline" org-deadline :transient t)
     ("S" "schedule" org-schedule :transient t)
     ("/" "comment" org-toggle-comment :transient t)
     ("C-w" "cut tree" org-cut-special :transient t)
     ("C-y" "yank tree" org-paste-special :transient t)]
    ["Make new/delete"
     :if org-at-heading-p
     ("mh" "make heading (before)" org-insert-heading)
     ("mH" "make heading (after)" org-insert-heading-after-current)
     ("mt" "make todo (before)" org-insert-todo-heading)
     ("mT" "make todo (after)" org-menu-insert-todo-heading-after-current)
     ("dh" "delete heading" org-cut-subtree :transient t)
     ("dy" "delete property" org-delete-property :transient t)
     ("a" "attachments" org-menu-attachments :transient t)]

    ;; Items for tables
    ["Navigate"
     :if org-at-table-p
     ("p" "up" previous-line :transient t)
     ("n" "down" next-line :transient t)
     ("b" "left" org-table-previous-field :transient t)
     ("f" "right" org-table-next-field :transient t)
     ("u" "parent" outline-up-heading :transient t)
     ("M-w" "store link" org-store-link :transient t :if-not region-active-p)
     ("C-_" "undo" undo :transient t)]
    ["Move r/c"
     :if org-at-table-p
     ("P" "up" org-table-move-row-up :transient t)
     ("N" "down" org-table-move-row-down :transient t)
     ("B" "left" org-table-move-column-left :transient t)
     ("F" "right" org-table-move-column-right :transient t)]
    ["Field"
     :if org-at-table-p
     ("'" "edit" org-table-edit-field)
     ("SPC" "blank" org-table-blank-field :transient t)
     ("RET" "from above" org-table-copy-down :transient t)
     ("t" "text formatting" org-menu-text-in-element)]
    ["Formulas"
     :if org-at-table-p
     ("E" "edit all" org-table-edit-formulas :transient t)
     ("=" "field" (lambda () (interactive) (org-table-eval-formula '(4))) :transient t)
     ("+" "in place" (lambda () (interactive) (org-table-eval-formula '(16))))
     ("c" "column" org-table-eval-formula :transient t)
     ("h" "coordinates" org-table-toggle-coordinate-overlays :transient t)
     ("D" "debug" org-table-toggle-formula-debugger :transient t)]
    ["Table"
     :if org-at-table-p
     ("dr" "delete row" org-shiftmetaup :transient t)
     ("dc" "delete column" org-shiftmetaleft :transient t)
     ("m" "make" org-menu-insert-table)
     ,@(when (fboundp (function org-table-toggle-column-width))
         (list '("S" "shrink column" org-table-toggle-column-width :transient t)))
     ("r" "sort" org-table-sort-lines :transient t)
     ("M-w" "copy rect" org-table-copy-region :transient t :if region-active-p)
     ("C-w" "cut rect" org-table-cut-region :transient t :if region-active-p)
     ("C-y" "yank rect" org-table-paste-rectangle :transient t)]

    ;; Items for lists
    ["Navigate"
     :if org-in-item-p
     ("p" "prev" previous-line :transient t)
     ("n" "next" next-line :transient t)
     ("c" "cycle" org-cycle :transient t)
     ("u" "parent" org-up-element :transient t)
     ("M-p" "prev (same level)" org-backward-element :transient t)
     ("M-n" "next (same level)" org-forward-element :transient t)
     ("M-w" "store link" org-store-link :transient t :if-not region-active-p)
     ("C-_" "undo" undo :transient t)]
    ["Move list"
     :if org-in-item-p
     ("P" "up" org-metaup :transient t)
     ("N" "down" org-metadown :transient t)
     ("B" "left" org-shiftmetaleft :transient t)
     ("F" "right" org-shiftmetaright :transient t)
     ("b" "left (line)" org-metaleft :transient t)
     ("f" "right (line)" org-metaright :transient t)]
    ["List"
     :if org-in-item-p
     ("R" "repair" org-list-repair)
     ("*" "turn into tree" org-list-make-subtree)
     ("S" "sort" org-sort-list :transient t)
     ("t" "text formatting" org-menu-text-in-element)]
    ["Toggle"
     :if org-in-item-p
     ("-" "list item" org-toggle-item :if-not org-at-table-p :transient t)
     ("+" "list style" org-cycle-list-bullet :if-not org-at-table-p :transient t)
     ("d" "done" org-toggle-checkbox :transient t)
     ("m" "checkbox" org-menu-toggle-has-checkbox :transient t)]

    ;; Items for text
    ,@(org-menu-text-format-items t)
    ["Line"
     :if org-menu-at-text-p
     (":" "fixed width" org-toggle-fixed-width :transient t)
     (";" "comment" org-menu-comment-line :transient t)
     ("--" "list" org-toggle-item :transient t)
     ("-*" "heading" org-ctrl-c-star :transient t)]

    ;; Items for source blocks
    ,@(org-menu-eval-src-items)

    ["Link"
     :if org-menu-in-link
     ("e" "edit" org-insert-link :transient t)]

    ["Timestamp"
     :if org-menu-in-time-p
     ("." "type" org-toggle-timestamp-type :transient t)
     ("e" "edit" org-time-stamp :transient t)]

    ["Tasks"
     ("v" "visibility" org-menu-visibility)
     ("x" "evaluation" org-menu-eval)
     ("i" "insert" org-menu-insert)
     ("g" "go to" org-menu-goto)
     ("s" "search" org-menu-search-and-filter)
     ("o" "options" org-menu-options)
     ("C" "clock (active)" org-menu-clock :if org-clock-is-active)
     ("C" "clock" org-menu-clock :if-not org-clock-is-active)
     ,@(when (fboundp #'org-capture-finalize)
         (list '("C-c C-c" "confirm capture" org-capture-finalize :if-non-nil org-capture-mode)))
     ,@(when (fboundp #'org-capture-kill)
         (list '("C-c C-k" "abort capture" org-capture-kill :if-non-nil org-capture-mode)))
     ("" "" transient-noop)
     ("q" "quit" transient-quit-all :if-non-nil org-menu-use-q-for-quit)
     ]])

(provide 'org-menu)
;;; org-menu.el ends here
