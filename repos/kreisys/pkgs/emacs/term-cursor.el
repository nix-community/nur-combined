;;; term-cursor.el --- Change cursor shape in terminal -*- lexical-binding: t; coding: utf-8; -*-

;; Version: 0.3
;; Author: h0d
;; URL: https://github.com/h0d
;; Keywords: terminals
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:

;; Send terminal escape codes to change cursor shape in TTY Emacs.
;; Using VT520 DECSCUSR (cf https://invisible-island.net/xterm/ctlseqs/ctlseqs.html).
;; Does not interfere with GUI Emacs behavior.

;;; Code:

(defgroup term-cursor nil
  "Group for term-cursor."
  :group 'terminals
  :prefix 'term-cursor-)

(defcustom term-cursor-bar-escape-code "\e[5 q"
  "The escape code sent to terminal to set the cursor as a bar."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-underline-escape-code "\e[3 q"
  "The escape code sent to terminal to set the cursor as an underscore."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-block-escape-code "\e[1 q"
  "The escape code sent to terminal to set the cursor as a box."
  :type 'string
  :group 'term-cursor)

;;;###autoload
(define-minor-mode term-cursor-mode
  "Minor mode for term-cursor."
  :group 'term-cursor
  (if term-cursor-mode
      (term-cursor-watch)
    (term-cursor-unwatch)))

;;;###autoload
(define-globalized-minor-mode global-term-cursor-mode term-cursor-mode
  (lambda ()
    (term-cursor-mode t))
  :group 'term-cursor)

(defun term-cursor-watcher (_symbol cursor operation _watch)
  "Change cursor shape through escape sequences depending on CURSOR.
Waits for OPERATION to be 'set."
  (unless (or (display-graphic-p)       	; Must be in TTY
	      (not (eq operation 'set)))        ; A new value must be set to the variable

    ;; CURSOR can be a `cons' (cf. `C-h v cursor-type')
    ;; In that case, extract actual cursor type
    (when (eq (type-of cursor) 'cons)
      (setq cursor (car cursor)))

    ;; Compare values and send corresponding escape code
    (cond (;; Vertical bar
	   (eq cursor 'bar)
	   (send-string-to-terminal term-cursor-bar-escape-code))
	  (;; Underscore
	   (eq cursor 'hbar)
	   (send-string-to-terminal term-cursor-underline-escape-code))
	  (;; Box — default value
	   t
	   (send-string-to-terminal term-cursor-block-escape-code)))))

(defun term-cursor-watch ()
  "Start watching cursor change."
  (add-variable-watcher 'cursor-type #'term-cursor-watcher))

(defun term-cursor-unwatch ()
  "Stop watching cursor change."
  (remove-variable-watcher 'cursor-type #'term-cursor-watcher))

(provide 'term-cursor)

;;; term-cursor.el ends here
