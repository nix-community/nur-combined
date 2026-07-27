;;; config-editing.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Editing configuration
;;; Code:

(setq-default enable-remote-dir-locals t)

;; When finding file in non-existing directory, offer to create the
;; parent directory.
(defun with-buffer-name-prompt-and-make-subdirs ()
  (let ((parent-directory (file-name-directory buffer-file-name)))
    (when (and (not (file-exists-p parent-directory))
               (y-or-n-p (format "Directory `%s' does not exist! Create it? " parent-directory)))
      (make-directory parent-directory t))))

(add-to-list 'find-file-not-found-functions #'with-buffer-name-prompt-and-make-subdirs)

;; Fix long line "problems"
;; Disable some right-to-left behavior that might not be needed.
;; Learning arabic might make me change this, but for now..
(setq-default bidi-paragraph-direction 'left-to-right)
(if (version<= "27.1" emacs-version)
    (setq bidi-inhibit-bpa t))
;; Detect if the line in a buffer are so long they could have a performance impact
(if (version<= "27.1" emacs-version)
    (global-so-long-mode 1))

(use-package saveplace
  :unless noninteractive
  :config
  (save-place-mode 1))

(use-package vundo
  :bind (("M-u"   . undo)
         ("M-U"   . undo-redo)
         ("C-x u" . vundo)))

(use-package whitespace
  :unless noninteractive
  :commands (whitespace-mode vde/toggle-invisibles)
  :config
  (setq-default whitespace-style '(face tabs spaces trailing space-before-tab newline indentation empty space-after-tab space-mark tab-mark newline-mark))
  (defun vde/toggle-invisibles ()
    "Toggles the display of indentation and space characters."
    (interactive)
    (if (bound-and-true-p whitespace-mode)
        (whitespace-mode -1)
      (whitespace-mode)))
  :bind ("<f6>" . vde/toggle-invisibles))

(use-package easy-kill
  :unless noninteractive
  :commands (easy-kill)
  :config
  (global-set-key [remap kill-ring-save] 'easy-kill)
  (global-set-key [remap mark-sexp] 'easy-mark))

(use-package display-line-numbers
  :unless noninteractive
  :hook (prog-mode . display-line-numbers-mode)
  :config
  (setq-default display-line-numbers-type 'relative)
  (defun vde/toggle-line-numbers ()
    "Toggles the display of line numbers.  Applies to all buffers."
    (interactive)
    (if (bound-and-true-p display-line-numbers-mode)
        (display-line-numbers-mode -1)
      (display-line-numbers-mode)))
  :bind ("<f7>" . vde/toggle-line-numbers))

(add-hook 'prog-mode-hook 'toggle-truncate-lines)

(use-package newcomment
  :unless noninteractive
  :config
  (setq-default comment-empty-lines t
                comment-fill-column nil
                comment-multi-line t
                comment-style 'multi-line)
  (defun prot/comment-dwim (&optional arg)
    "Alternative to `comment-dwim': offers a simple wrapper
around `comment-line' and `comment-dwim'.

If the region is active, then toggle the comment status of the
region or, if the major mode defines as much, of all the lines
implied by the region boundaries.

Else toggle the comment status of the line at point."
    (interactive "*P")
    (if (use-region-p)
        (comment-dwim arg)
      (save-excursion
        (comment-line arg))))

  :bind (("C-;" . prot/comment-dwim)
         ("C-:" . comment-kill)
         ("M-;" . comment-indent)
         ("C-x C-;" . comment-box)))

(use-package delsel
  :unless noninteractive
  :config
  (delete-selection-mode 1))

(use-package emacs
  :unless noninteractive
  :custom
  (repeat-on-final-keystroke t)
  (set-mark-command-repeat-pop t)
  :bind (("M-z" . zap-up-to-char)
	 ("M-S-<up>" . duplicate-dwim)))

(use-package visual-regexp
  :unless noninteractive
  :commands (vr/replace vr/query-replace)
  :bind (("C-c r"   . vr/replace)
         ("C-c %"   . vr/query-replace)))

(use-package emacs
  :config
  :bind (("M-SPC" . cycle-spacing)
         ("M-o" . delete-blank-lines)
         ("<C-f6>" . tear-off-window)))

;; (use-package pdf-tools
;;   :unless noninteractive
;;   :mode  ("\\.pdf\\'" . pdf-view-mode)
;;   :config
;;   (setq-default pdf-view-display-size 'fit-page)
;;   (setq pdf-annot-activate-created-annotations t)
;;   (setq pdf-view-midnight-colors '("#ffffff" . "#000000"))
;;   (pdf-tools-install :no-query)
;;   (require 'pdf-occur))

(use-package scratch
  :unless noninteractive
  :commands (scratch)
  :config
  (defun vde/scratch-buffer-setup ()
    "Add contents to `scratch' buffer and name it accordingly.
If region is active, add its contents to the new buffer."
    (let* ((mode major-mode)
           (string (format "Scratch buffer for: %s\n\n" mode))
           (region (with-current-buffer (current-buffer)
                     (if (region-active-p)
                         (buffer-substring-no-properties
                          (region-beginning)
                          (region-end)))
                     ""))
           (text (concat string region)))
      (when scratch-buffer
        (save-excursion
          (insert text)
          (goto-char (point-min))
          (comment-region (point-at-bol) (point-at-eol)))
        (forward-line 2))
      (rename-buffer (format "*Scratch for %s*" mode) t)))
  :hook (scratch-create-buffer . vde/scratch-buffer-setup)
  :bind ("C-c s" . scratch))

(use-package subword
  :diminish
  :hook (prog-mode-hook . subword-mode))

;; (use-package selection-highlight-mode
;;   :preface
;;   (unless (package-installed-p 'selection-highlight-mode)
;;     (package-vc-install "https://github.com/balloneij/selection-highlight-mode"))
;;   :config (selection-highlight-mode))

(use-package surround  
  :bind-keymap ("M-'" . surround-keymap))

(use-package substitute
  :bind (("M-<insert> s" . substitute-target-below-point)
	 ("M-<insert> r" . substitute-target-above-point)
	 ("M-<insert> d" . substitute-target-in-defun)
	 ("M-<insert> b" . substitute-target-in-buffer)))

(use-package jinx
  :hook (emacs-startup . global-jinx-mode)
  :bind (([remap ispell-word] . jinx-correct) ;; ("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))

(use-package re-builder)
(use-package casual-re-builder
  :bind (:map
	 reb-mode-map ("C-o" . casual-re-builder-tmenu)
	 :map
	 reb-lisp-mode-map ("C-o" . casual-re-builder-tmenu))
  :after (re-builder))

(provide 'config-editing)
;;; config-editing.el ends here
