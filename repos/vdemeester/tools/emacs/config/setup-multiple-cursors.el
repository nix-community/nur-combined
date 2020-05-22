(use-package region-bindings-mode
  :disabled
  :config
  ;; Do not activate `region-bindings-mode' in Special modes like `dired' and
  ;; `ibuffer'. Single-key bindings like 'm' are useful in those modes even
  ;; when a region is selected.
  (setq region-bindings-mode-disabled-modes '(dired-mode ibuffer-mode))

  (region-bindings-mode-enable)

  (defun vde/disable-rbm-deactivate-mark ()
    "Disable `region-bindings-mode' and deactivate mark."
    (interactive)
    (region-bindings-mode -1)
    (deactivate-mark)
    (message "Mark deactivated"))

  (bind-keys
   :map region-bindings-mode-map
   ("<C-SPC>" . vde/disable-rbm-deactivate-mark)))

(use-package multiple-cursor
  :disabled
  :bind (:map region-bindings-mode-map
              ("a" . mc/mark-all-like-this)
              ("p" . mc/mark-previous-like-this)
              ("n" . mc/mark-next-like-this)
              ("P" . mc/unmark-previous-like-this)
              ("N" . mc/unmark-next-like-this)
              ("[" . mc/cycle-backward)
              ("]" . mc/cycle-forward)
              ("m" . mc/mark-more-like-this-extended)
              ("h" . mc-hide-unmatched-lines-mode)
              ("\\" . mc/vertical-align-with-space)
              ("#" . mc/insert-numbers) ; use num prefix to set the starting number
              ("^" . mc/edit-beginnings-of-lines)
              ("$" . mc/edit-ends-of-lines)))

(provide 'setup-multiple-cursors)
