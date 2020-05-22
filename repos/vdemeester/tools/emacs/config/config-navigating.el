;;; config-navigating.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Navigation related configuration
;;; Code:

(use-package avy
  :disabled
  :bind (("C-c j"   . avy-goto-word-1)
         ("C-c n b" . avy-pop-mark)
         ("C-c n j" . avy-goto-char-2)
         ("C-c n t" . avy-goto-char-timer)
         ("C-c n w" . avy-goto-word-1)))

(use-package hideshow
  :commands (hs-show-all hs-toggle-hiding hs-hide-all hs-hide-block hs-hide-level)
  :defer 5
  :bind (("C-c @ a" . hs-show-all)
         ("C-c @ c" . hs-toggle-hiding)
         ("C-c @ t" . hs-hide-all)
         ("C-c @ d" . hs-hide-block)
         ("C-c @ l" . hs-hide-level)))

(use-package mwim
  :commands (mwim-beginning-of-code-or-line mwim-end-of-code-or-line)
  :bind (:map prog-mode-map
              ("C-a" . mwim-beginning-of-code-or-line)
              ("C-e" . mwim-end-of-code-or-line)))

(use-package beginend
  :defer 5
  :config
  (beginend-global-mode 1))

(provide 'config-navigating)
;;; config-navigating.el ends here
