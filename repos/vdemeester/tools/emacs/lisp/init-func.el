;;; init-func.el --- -*- lexical-binding: t -*-
;;

;;;###autoload
(defun vde/el-load-dir (dir)
  "Load el files from the given folder `DIR'."
  (let ((files (directory-files dir nil "\.el$")))
    (while files
      (load-file (concat dir (pop files))))))

;;;###autoload
(defun vde/short-hostname ()
  "Return hostname in short (aka wakasu.local -> wakasu)."
  (string-match "[0-9A-Za-z-]+" system-name)
  (substring system-name (match-beginning 0) (match-end 0)))


(provide 'init-func)
;;; init-func.el ends here
