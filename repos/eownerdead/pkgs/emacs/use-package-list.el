;;; use-package-list.el --- List ensured packages -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'package)
(require 'use-package)

(defvar use-package-list-packages)

(setq use-package-list-packages '())

(advice-add 'use-package-handler/:hook :override #'ignore)

(defun ensure-dummy (name _args _state &optional _no-refresh)
  (unless (package-built-in-p name)
    (add-to-list 'use-package-list-packages name)))

(setq-default use-package-check-before-init nil
              use-package-ignore-unknown-keywords t
              use-package-ensure-function #'ensure-dummy)

(load-file (car argv))

(princ (json-encode use-package-list-packages))

(provide 'use-package-list)

;;; use-package-list.el ends here
