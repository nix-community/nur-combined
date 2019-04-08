(require 'package)
(package-initialize)

(load-theme 'oceanic t)
(set-frame-font "PragmataPro Liga")

;(display-line-numbers-type (quote visual))
;(global-display-line-numbers-mode t)
;(custom-set-variables
; '(display-line-numbers-type (quote visual))
; '(global-display-line-numbers-mode t)
; '(line-number-mode nil)
; '(menu-bar-mode nil)
; '(scroll-bar-mode nil)
; '(tool-bar-mode nil)
; )

;; ITERM2 MOUSE SUPPORT
(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (defun track-mouse (e))
  (setq mouse-sel-mode t)
)

(setq global-linum-mode t)
(global-display-line-numbers-mode)
(global-hl-line-mode 1)

(global-evil-leader-mode)
(evil-leader/set-leader ",")
(evil-leader/set-key
  "ci" 'evilnc-comment-or-uncomment-lines
  "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
  "ll" 'evilnc-quick-comment-or-uncomment-to-the-line
  "cc" 'evilnc-copy-and-comment-lines
  "cp" 'evilnc-comment-or-uncomment-paragraphs
  "cr" 'comment-or-uncomment-region
  "cv" 'evilnc-toggle-invert-comment-line-by-line
  "."  'evilnc-copy-and-comment-operator
  "\\" 'evilnc-comment-operator ; if you prefer backslash key
)
(evil-mode 1)
(powerline-default-theme)

(require 'term-cursor)
(global-term-cursor-mode)
