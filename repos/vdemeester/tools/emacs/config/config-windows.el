;;; config-windows.el ---  -*- lexical-binding: t; -*-
;; Commentary:
;;; Windows configuration
;; Code:

;; Winner
(use-package winner
  :unless noninteractive
  :defer 5
  :config
  (winner-mode 1))
;; -UseWinner

;; UseAceWindow
(use-package ace-window
  :commands (ace-window ace-swap-window)
  :bind (("C-x o"   . ace-window)
         ("C-c w w" . ace-window)
         ("C-c w s" . ace-swap-window))
  :config
  (setq-default aw-keys '(?a ?u ?i ?e ?, ?c ?t ?r ?m)
                aw-scope 'frame
                aw-dispatch-always t
                aw-dispatch-alist
                '((?s aw-swap-window "Swap Windows")
                  (?2 aw-split-window-vert "Split Window Vertically")
                  (?3 aw-split-window-horz "Split Window Horizontally")
                  (?? aw-show-dispatch-help))
                aw-minibuffer-flag t
                aw-ignore-current nil
                aw-display-mode-overlay t
                aw-background t))
;; -UseAceWindow

;; UseWindmove
(use-package windmove
  :commands (windmove-left windmove-right windmove-down windmove-up)
  :bind (("C-s-<up>" . windmove-up)
         ("C-s-<right>" . windmove-right)
         ("C-s-<down>" . windmove-down)
         ("C-s-<left>" . windmove-left)))
;; -UseWindmove

(provide 'config-windows)
;;; config-windows ends here
