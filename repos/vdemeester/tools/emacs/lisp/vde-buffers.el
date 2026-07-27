;;; vde-buffers.el --- -*- lexical-binding: t; -*-
;; Commentary:
;;; Helper function related to buffers
;; Code:

;;;###autoload
(defun vde/buffer-has-project-p (buffer action)
  (with-current-buffer buffer (project-current nil)))

(provide 'vde-buffers)
;;; vde-buffers.el ends here
