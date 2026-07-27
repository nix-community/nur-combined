;;; config-mouse.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Mouse configuration
;;; Code:

(use-package mouse
  :unless noninteractive
  :config
  (setq mouse-wheel-scroll-amount
        '(1
          ((shift) . 5)
          ((meta) . 0.5)
          ((control) . text-scale)))
  (setq make-pointer-invisible t
        mouse-wheel-progressive-speed t
        mouse-wheel-follow-mouse t)
  :hook (after-init . mouse-wheel-mode))

(provide 'config-mouse)
;;; config-mouse.el ends here
