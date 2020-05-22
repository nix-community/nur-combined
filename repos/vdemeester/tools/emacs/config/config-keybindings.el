;;; config-keybindings.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Key binding specific configuration
;;; Code:
(use-package which-key
  :disabled
  :init (which-key-mode)
  :custom
  (which-key-idle-delay 2)
  (which-key-idle-secondary-delay 0.05)
  (which-key-show-early-on-C-h t)
  (which-key-sort-order 'which-key-prefix-then-key-order)
  (which-key-popup-type 'side-window)
  (which-key-show-prefix 'echo)
  (which-key-max-display-columns 6)
  (which-key-separator " → ")
  :config
  (add-to-list 'which-key-replacement-alist '(("TAB" . nil) . ("↹" . nil)))
  (add-to-list 'which-key-replacement-alist '(("RET" . nil) . ("⏎" . nil)))
  (add-to-list 'which-key-replacement-alist '(("DEL" . nil) . ("⇤" . nil)))
  (add-to-list 'which-key-replacement-alist '(("SPC" . nil) . ("␣" . nil))))

;; Disable C-x C-n to avoid the disabled command buffer
(unbind-key "C-x C-n" global-map)

(provide 'config-keybindings)
;;; config-keybindings.el ends here
