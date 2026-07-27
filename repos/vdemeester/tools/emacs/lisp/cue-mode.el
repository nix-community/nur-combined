;;; cue-mode.el --- CUE Lang Major Mode          -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Russell Sim

;; Author: Russell Sim <russell.sim@gmail.com>
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'smie)
(require 'cl-extra)

(defgroup cue '()
  "Major mode for editing Cue files."
  :group 'languages)

(defcustom cue-eval-command
  '("cue" "eval")
  "Cue command to run in ‘cue-eval-buffer’.
See also: `cue-command-options'."
  :type '(repeat string)
  :group 'cue)

(defcustom cue-command-options
  '()
  "A list of options and values to pass to `cue-command'.
For example:
  '(\"-e\" \"Nginx.Out\" \"--out=text\")"
  :group 'cue
  :type '(repeat string))

(defcustom cue-fmt-command
  '("cue" "fmt")
  "Cue format command."
  :type '(repeat string)
  :group 'cue)


(defcustom cue-library-search-directories
  nil "Sequence of Cue package search directories."
  :type '(repeat directory)
  :group 'cue)

(defcustom cue-indent-level
  4
  "Number of spaces to indent with."
  :type '(number)
  :group 'cue)

(defvar cue--identifier-regexp
  "[a-zA-Z_][a-zA-Z0-9_]*"
  "Regular expression matching a Cue identifier.")

(defvar cue-font-lock-keywords
  (let ((builtin-regex (regexp-opt '("package" "import" "for" "in" "if" "let") 'words))
        (constant-regex (regexp-opt '("false" "null" "true") 'words))
        ;; All builtin functions (see https://cue.org/docs/references/spec/#builtin-functions)
        (standard-functions-regex (regexp-opt '("len" "close" "and" "or" "div" "mod" "quo" "rem") 'words)))
    (list
     `(,builtin-regex . font-lock-builtin-face)
     `(,constant-regex . font-lock-constant-face)
     ;; identifiers starting with a # or _ are reserved for definitions
     ;; and hidden fields
     `(,(concat "_?#" cue--identifier-regexp "+:?") . font-lock-type-face)
     `(,(concat cue--identifier-regexp "+:") . font-lock-keyword-face)
     ;; all identifiers starting with __(double underscores) as keywords
     `(,(concat "__" cue--identifier-regexp) . font-lock-keyword-face)
     `(,standard-functions-regex . font-lock-function-name-face)))
  "Minimal highlighting for ‘cue-mode’.")

(defun cue-syntax-stringify ()
  "Put `syntax-table' property correctly on single/triple quotes."
  (let* ((ppss (save-excursion (backward-char 3) (syntax-ppss)))
         (string-start (and (eq t (nth 3 ppss)) (nth 8 ppss)))
         (quote-starting-pos (- (point) 3))
         (quote-ending-pos (point)))
    (cond ((or (nth 4 ppss)             ;Inside a comment
               (and string-start
                    ;; Inside of a string quoted with different triple quotes.
                    (not (eql (char-after string-start)
                              (char-after quote-starting-pos)))))
           ;; Do nothing.
           nil)
          ((nth 5 ppss)
           ;; The first quote is escaped, so it's not part of a triple quote!
           (goto-char (1+ quote-starting-pos)))
          ((null string-start)
           ;; This set of quotes delimit the start of a string.
           (put-text-property quote-starting-pos (1+ quote-starting-pos)
                              'syntax-table (string-to-syntax "|")))
          (t
           ;; This set of quotes delimit the end of a string.
           (put-text-property (1- quote-ending-pos) quote-ending-pos
                              'syntax-table (string-to-syntax "|"))))))


(defvar cue-smie-verbose-p nil
  "Emit context information about the current syntax state.")

(defmacro cue-smie-debug (message &rest format-args)
  `(progn
     (when cue-smie-verbose-p
       (message (format ,message ,@format-args)))
     nil))

(defun verbose-cue-smie-rules (kind token)
  (let ((value (cue-smie-rules kind token)))
    (cue-smie-debug "%s '%s'; sibling-p:%s prev-is-OP:%s hanging:%s == %s" kind token
                    (ignore-errors (smie-rule-sibling-p))
                    (ignore-errors (smie-rule-prev-p "OP"))
                    (ignore-errors (smie-rule-hanging-p))
                    value)
    value))

(defvar cue-smie-grammar
  (smie-prec2->grammar
   (smie-merge-prec2s
    (smie-bnf->prec2
     '((exps (exp "," exp))
       (exp (field)
            ("import" id)
            ("package" id)
            (id))
       (field (id ":" exp))
       (id))
     '((assoc ",") (assoc "\n") (left ":") (left ".") (left "let"))
     '((right "=")))

    (smie-precs->prec2
     '((right "=")
       (left "||" "|")
       (left "&&" "&")
       (nonassoc "=~" "!~" "!=" "==" "<=" ">=" "<" ">")
       (left "+" "-")
       (left "*" "/"))))))

;; Operators
;; +     &&    ==    <     =     (     )
;; -     ||    !=    >     :     {     }
;; *     &     =~    <=    ?     [     ]     ,
;; /     |     !~    >=    !     _|_   ...   .
;; _|_ bottom

(defun cue-smie-rules (kind token)
  (pcase (cons kind token)
    (`(:elem . basic) smie-indent-basic)
    (`(,_ . ",") (cue-smie--indent-nested))
    (`(,_ . "}") (cue-smie--indent-closing))
    (`(,_ . "]") (smie-rule-parent (- 0 cue-indent-level)))
    (`(,_ . ")") (smie-rule-parent (- 0 cue-indent-level)))
    ))

(defun cue-smie--in-object-p ()
  "Return t if the current block we are in is wrapped in {}."
  (let ((ppss (syntax-ppss)))
    (or (null (nth 1 ppss))
        (and (nth 1 ppss)
             (or
              (eq ?{ (char-after (nth 1 ppss)))
              (eq ?\( (char-after (nth 1 ppss))))))))


(defun cue-smie-backward-token ()
  (let ((pos (point)))
    (forward-comment (- (point)))
    (cond
     ((and (not (eq (char-before) ?\,)) ;Coalesce ";" and "\n".
           (> pos (line-end-position))
           (cue-smie--in-object-p))
      (skip-chars-forward " \t")
      ;; Why bother distinguishing \n and ,?
      ",") ;;"\n"
     (t
      (buffer-substring-no-properties
       (point)
       (progn (if (zerop (skip-syntax-backward "."))
                  (skip-syntax-backward "w_'"))
              (point)))))))


(defun cue-smie-forward-token ()
  (skip-chars-forward " \t")
  (cond
   ((and (looking-at "[\n]")
         (or (save-excursion (skip-chars-backward " \t")
                             ;; Only add implicit , when needed.
                             (or (bolp) (eq (char-before) ?\,)))
             (cue-smie--in-object-p)))
    (if (eolp) (forward-char 1) (forward-comment 1))
    ;; Why bother distinguishing \n and ;?
    ",") ;;"\n"
   ((progn (forward-comment (point-max)) nil))
   (t
    (buffer-substring-no-properties
     (point)
     (progn (if (zerop (skip-syntax-forward "."))
                (skip-syntax-forward "w_'"))
            (point))))))

(defun cue-smie--indent-nested ()
  (let ((ppss (syntax-ppss)))
    (if (nth 1 ppss)
        (let ((parent-indentation (save-excursion
                                    (goto-char (nth 1 ppss))
                                    (back-to-indentation)
                                    (current-column))))
          (cons 'column (+ parent-indentation cue-indent-level))))))

(defun cue-smie--indent-closing ()
  (let ((ppss (syntax-ppss)))
    (if (nth 1 ppss)
        (let ((parent-indentation (save-excursion
                                    (goto-char (nth 1 ppss))
                                    (back-to-indentation)
                                    (current-column))))
          (cons 'column parent-indentation)))))

(defvar cue-syntax-propertize-function
  (syntax-propertize-rules
   ((rx (or "\"\"\"" "'''"))
    (0 (ignore (cue-syntax-stringify))))))

(defconst cue-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; Comments. Cue supports /* */ and // as comment delimiters
    (modify-syntax-entry ?/ ". 124" table)
    ;; Additionally, Cue supports # as a comment delimiter
    (modify-syntax-entry ?\n ">" table)
    ;; ", ', ,""" and ''' are quotations in Cue.
    ;; both """ and ''' are handled by cue--syntax-propertize-function
    (modify-syntax-entry ?' "\"" table)
    (modify-syntax-entry ?\" "\"" table)
    ;; Our parenthesis, braces and brackets
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\{ "(}" table)
    (modify-syntax-entry ?\} "){" table)
    (modify-syntax-entry ?\[ "(]" table)
    (modify-syntax-entry ?\] ")[" table)
    table)
  "Syntax table for `cue-mode'.")


;;;###autoload
(define-derived-mode cue-mode prog-mode "CUE Lang Mode"
  :syntax-table cue-mode-syntax-table
  (setq-local font-lock-defaults '(cue-font-lock-keywords ;; keywords
                                   nil  ;; keywords-only
                                   nil  ;; case-fold
                                   nil  ;; syntax-alist
                                   nil  ;; syntax-begin
                                   ))

  (setq-local syntax-propertize-function
              cue-syntax-propertize-function)

  ;; cue lang uses tabs for indent by default
  (setq-local indent-tabs-mode t)
  (setq-local tab-width cue-indent-level)

  (smie-setup cue-smie-grammar 'verbose-cue-smie-rules
              :forward-token  #'cue-smie-forward-token
              :backward-token #'cue-smie-backward-token)
  (setq-local smie-indent-basic cue-indent-level)
  (setq-local smie-indent-functions '(smie-indent-fixindent
                                      smie-indent-bob
                                      smie-indent-comment
                                      smie-indent-comment-continue
                                      smie-indent-comment-close
                                      smie-indent-comment-inside
                                      smie-indent-keyword
                                      smie-indent-after-keyword
                                      smie-indent-empty-line
                                      smie-indent-exps))

  (setq-local comment-start "// ")
  (setq-local comment-start-skip "//+[\t ]*")
  (setq-local comment-end "")
  )

;;;###autoload
(add-to-list 'auto-mode-alist (cons "\\.cue\\'" 'cue-mode))

;;;###autoload
(defun cue-eval-buffer ()
  "Run cue with the path of the current file."
  (interactive)
  (let ((file-to-eval (file-truename (buffer-file-name)))
        (search-dirs cue-library-search-directories)
        (output-buffer-name "*cue output*"))
    (save-some-buffers (not compilation-ask-about-save)
                       (let ((directories (cons (file-name-directory file-to-eval)
                                                search-dirs)))
                         (lambda ()
                           (member (file-name-directory (file-truename (buffer-file-name)))
                                   directories))))
    (let ((cmd (car cue-eval-command))
          (args (append (cdr cue-eval-command)
                        cue-command-options
                        (cl-loop for dir in search-dirs
                                 collect "-I"
                                 collect dir)
                        (list file-to-eval))))
      (let ((outbuf (get-buffer-create output-buffer-name)))
        (with-current-buffer outbuf
          (let ((origional-point (point)))
            (setq buffer-read-only nil)
            (erase-buffer)
            (if (zerop (apply #'call-process cmd nil t nil args))
                (progn
                  (cue-mode)
                  (view-mode))
              (compilation-mode nil))
            (goto-char origional-point)))
        (display-buffer outbuf '(nil (allow-no-window . t)))))))

(define-key cue-mode-map (kbd "C-c C-c") 'cue-eval-buffer)


;;;###autoload
(defun cue-reformat-buffer ()
  "Reformat entire buffer using the Cue format utility."
  (interactive)
  (let ((point (point))
        (file-name (buffer-file-name))
        (stdout-buffer (get-buffer-create "*cue fmt stdout*"))
        (stderr-buffer-name "*cue fmt stderr*")
        (stderr-file (make-temp-file "cue fmt")))
    (when-let ((stderr-window (get-buffer-window stderr-buffer-name t)))
      (quit-window nil stderr-window))
    (unwind-protect
        (let* ((only-test buffer-read-only)
               (exit-code (apply #'call-process-region nil nil (car cue-fmt-command)
                                 nil (list stdout-buffer stderr-file) nil
                                 (append (cdr cue-fmt-command)
                                         (when only-test '("--test"))
                                         '("-")))))
          (cond ((zerop exit-code)
                 (progn
                   (if (or only-test
                           (zerop (compare-buffer-substrings nil nil nil stdout-buffer nil nil)))
                       (message "No format change necessary.")
                     (erase-buffer)
                     (insert-buffer-substring stdout-buffer)
                     (goto-char point))
                   (kill-buffer stdout-buffer)))
                ((and only-test (= exit-code 2))
                 (message "Format change is necessary, but buffer is read-only."))
                (t (with-current-buffer (get-buffer-create stderr-buffer-name)
                     (setq buffer-read-only nil)
                     (insert-file-contents stderr-file t nil nil t)
                     (goto-char (point-min))
                     (when file-name
                       (while (search-forward "<stdin>" nil t)
                         (replace-match file-name)))
                     (set-buffer-modified-p nil)
                     (compilation-mode nil)
                     (display-buffer (current-buffer)
                                     '((display-buffer-reuse-window
                                        display-buffer-at-bottom
                                        display-buffer-pop-up-frame)
                                       .
                                       ((window-height . fit-window-to-buffer))))))))
      (delete-file stderr-file))))

(define-key cue-mode-map (kbd "C-c C-r") 'cue-reformat-buffer)

(provide 'cue-mode)
;;; cue-mode.el ends here
