(require 'package)

(setq packages nil)

(defun ensure-dummy (name _args _state &optional _no-refresh)
  (unless (package-built-in-p name)
    (add-to-list 'packages name)))

(setq-default use-package-ignore-unknown-keywords t
              use-package-ensure-function #'ensure-dummy)

(load-file (car argv))

(princ (json-encode packages))

