;;; vde-windows.el --- -*- lexical-binding: t; -*-
;; Commentary:
;;; Helper function related to window management
;; Code:

;;;###autoload
(defun vde/split-window-below (arg)
  "Split window below from the parent or from the roo with ARG."
  (interactive "P")
  (split-window (if arg (frame-root-window)
		 (window-parent (selected-window)))
	       nil 'below nil))

;;;###autoload
(defun vde/split-window-right (arg)
  "Split window right from the parent or from the roo with ARG."
  (interactive "P")
  (split-window (if arg (frame-root-window)
		 (window-parent (selected-window)))
		nil 'right nil))

;;;###autoload
(defun vde/toggle-window-dedication ()
  "Toggles window dedication in the selected window."
  (interactive)
  (set-window-dedicated-p (selected-window)
			  (not (window-dedicated-p (selected-window)))))

;;;###autoload
(defun make-display-buffer-matcher-function (major-modes)
  (lambda (buffer-name action)
    (with-current-buffer buffer-name (apply #'derived-mode-p major-modes))))

(provide 'vde-windows)
;;; vde-windows.el ends here
