;;; config-completion.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Setup completion framework
;;; Code

(use-package consult
  :bind
  ("M-g M-g" . consult-goto-line)
  ("M-K" . consult-keep-lines)
  ("M-s M-b" . consult-buffer)
  ("M-s M-f" . consult-find)
  ("M-s M-g" . consult-grep)
  ("M-s M-r" . consult-ripgrep)
  ("M-s M-h" . consult-history)
  ("M-s M-i" . consult-imenu)
  ("M-s M-l" . consult-line)
  ("M-s M-m" . consult-mark)
  ("M-s M-y" . consult-yank-pop)
  ("M-s M-s" . consult-outline))

(use-package consult-xref
  :config
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  (defvar consult--xref-history nil
    "History for the `consult-recent-xref' results.")

  (defun consult-recent-xref (&optional markers)
    "Jump to a marker in MARKERS list (defaults to `xref--history'.

The command supports preview of the currently selected marker position.
The symbol at point is added to the future history."
    (interactive)
    (consult--read
     (consult--global-mark-candidates
      (or markers (flatten-list xref--history)))
     :prompt "Go to Xref: "
     :annotate (consult--line-prefix)
     :category 'consult-location
     :sort nil
     :require-match t
     :lookup #'consult--lookup-location
     :history '(:input consult--xref-history)
     :add-history (thing-at-point 'symbol)
     :state (consult--jump-state))))

;; https://github.com/oantolin/embark/blob/master/embark-consult.el
(use-package embark
  :unless noninteractive
  :bind
  ("C-." . embark-act)
  ("M-." . embark-dwim)
  ("C-h b" . embark-bindings)
  ("C-h B" . embark-bindings-at-point)
  ("C-h M" . embark-bindings-in-keymap)
  ("C-h E" . embark-on-last-message)
  (:map completion-list-mode-map
        ("." . embark-act))
  (:map embark-collect-mode-map
        ("a") ; I don't like my own default :)
        ("." . embark-act)
        ("F" . consult-focus-lines))
  (:map embark-package-map
        ("t" . try))
  (:map embark-identifier-map
        ("(" . insert-parentheses)
        ("[" . insert-pair-map))
  (:map embark-expression-map
        ("(" . insert-parentheses)
        ("[" . insert-pair-map))
  (:map embark-region-map
        ("(" . insert-parentheses)
        ("[" . insert-pair-map)
        ("D" . dictionary-search))
  (:map embark-email-map
        ("+" . add-email-to-ecomplete)
        ("\\" . remove-email-from-ecomplete))
  (:map embark-encode-map
        ("p" . topaz-paste-region))
  (:map embark-url-map
        ("x" . browse-url-generic)
        ("p" . pocket-lib-add-urls))
  (:map embark-identifier-map
        ("D" . dictionary-lookup-definition))
  :custom
  (embark-quit-after-action t)
  (prefix-help-command #'embark-prefix-help-command)
  (embark-indicators '(embark-minimal-indicator
                       embark-highlight-indicator
                       embark-isearch-highlight-indicator))
  (embark-cycle-key ".")
  (embark-help-key "?")
  (embark-confirm-act-all nil)
  :config
  (setq embark-candidate-collectors
        (cl-substitute 'embark-sorted-minibuffer-candidates
                       'embark-minibuffer-candidates
                       embark-candidate-collectors))
  (dolist (cmd '(comment-dwim
                 insert-parentheses
                 insert-pair
                 markdown-insert-code
                 markdown-insert-italic
                 markdown-insert-bold
                 org-emphasize
                 cdlatex-math-modify
                 TeX-font))
    (push #'embark--mark-target (alist-get cmd embark-around-action-hooks)))
  (push #'embark--xref-push-marker
        (alist-get 'find-file embark-pre-action-hooks))
  (defun embark-on-last-message (arg)
    "Act on the last message displayed in the echo area."
    (interactive "P")
    (with-current-buffer "*Messages*"
      (goto-char (1- (point-max)))
      (embark-act arg)))

  (defmacro ct/embark-display-in-side-window (side)
    `(defun ,(intern (concat "display-in-side-window--" (symbol-name side))) (&optional buffer)
       (interactive "b")
       (when-let* ((buffer (or buffer (current-buffer)))
                   (display-buffer-overriding-action '((display-buffer-in-side-window)
                                                       (dedicated . t)
                                                       (side . ,side)
                                                       (window-parameters . ((no-delete-other-windows . t))))))
	 (display-buffer buffer))))
  (define-key embark-buffer-map (kbd "s b") (ct/embark-display-in-side-window bottom))
  (define-key embark-buffer-map (kbd "s l") (ct/embark-display-in-side-window left))
  (define-key embark-buffer-map (kbd "s r") (ct/embark-display-in-side-window right))
)

(use-package embark-consult
  :unless noninteractive
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package emacs
  :unless noninteractive
  :custom
  (completion-cycle-threshold 2)
  (completion-ignore-case t)
  (completion-show-inline-help nil)
  (completions-detailed t)
  (enable-recursive-minibuffers t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  (resize-mini-windows t)
  :config
  (minibuffer-depth-indicate-mode 1)
  (minibuffer-electric-default-mode 1))

(use-package mct
  :unless noninteractive
  :custom
  (mct-completion-window-size (cons #'mct-frame-height-third 1))
  (mct-remove-shadowed-file-names t) ; works when `file-name-shadow-mode' is enabled
  (mct-hide-completion-mode-line t)
  (mct-minimum-input 3)
  (mct-live-completion 'visible)
  (mct-live-update-delay 0.6)
  (mct-persist-dynamic-completion t)
  :config
  (mct-mode 1)
  (defun my-sort-by-alpha-length (elems)
    "Sort ELEMS first alphabetically, then by length."
    (sort elems (lambda (c1 c2)
                  (or (string-version-lessp c1 c2)
                      (< (length c1) (length c2))))))

  (defun my-sort-by-history (elems)
    "Sort ELEMS by minibuffer history.
Use `mct-sort-sort-by-alpha-length' if no history is available."
    (if-let ((hist (and (not (eq minibuffer-history-variable t))
			(symbol-value minibuffer-history-variable))))
	(minibuffer--sort-by-position hist elems)
      (my-sort-by-alpha-length elems)))

  (defun my-sort-multi-category (elems)
    "Sort ELEMS per completion category."
    (pcase (mct--completion-category)
      ('nil elems) ; no sorting
      ('kill-ring elems)
      ('project-file (my-sort-by-alpha-length elems))
      (_ (my-sort-by-history elems))))

  ;; Specify the sorting function.
  (setq completions-sort #'my-sort-multi-category)

  ;; Add prompt indicator to `completing-read-multiple'.  We display
  ;; [`completing-read-multiple': <separator>], e.g.,
  ;; [`completing-read-multiple': ,] if the separator is a comma.  This
  ;; is adapted from the README of the `vertico' package by Daniel
  ;; Mendler.  I made some small tweaks to propertize the segments of
  ;; the prompt.
  (defun crm-indicator (args)
    (cons (format "[`crm-separator': %s]  %s"
                  (propertize
                   (replace-regexp-in-string
                    "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                    crm-separator)
                   'face 'error)
                  (car args))
          (cdr args)))

  (advice-add #'completing-read-multiple :filter-args #'crm-indicator))

(use-package marginalia
  :unless noninteractive
  :config
  (marginalia-mode 1))

(use-package corfu
  :unless noninteractive
  :bind (("C-<tab>" . corfu-candidate-overlay-complete-at-point))
  :init
  (require 'corfu-popupinfo)
  (require 'corfu-history)
  (require 'corfu-candidate-overlay)
  :config
  (global-corfu-mode 1)
  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1)
  (corfu-candidate-overlay-mode)
    ;; Sort by input history (no need to modify `corfu-sort-function').
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history))

  ;; Adapted from Corfu's manual.
  (defun contrib/corfu-enable-always-in-minibuffer ()
    "Enable Corfu in the minibuffer if MCT or Vertico is not active.
Useful for prompts such as `eval-expression' and `shell-command'."
    (unless (or (bound-and-true-p vertico--input)
                (bound-and-true-p mct--active))
      (corfu-mode 1)))

  (add-hook 'minibuffer-setup-hook #'contrib/corfu-enable-always-in-minibuffer 1))

(use-package corfu-candidate-overlay
  :after corfu
  :bind (("C-<tab>" . corfu-candidate-overlay-complete-at-point))
  :config
  (corfu-candidate-overlay-mode +1))

(use-package cape
  :bind (("C-c p f" . cape-file)
         ("C-c p /" . cape-dabbrev)
         :map corfu-map
         ("M-/" . cape-dabbrev)
         ("C-x C-f" . cape-file))
  :config
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package orderless
  :unless noninteractive
  :config
  ;; We make the SPC key insert a literal space and the same for the
  ;; question mark.  Spaces are used to delimit orderless groups, while
  ;; the quedtion mark is a valid regexp character.
  (let ((map minibuffer-local-completion-map))
    (define-key map (kbd "SPC") nil)
    (define-key map (kbd "?") nil))

  ;; Because SPC works for Orderless and is trivial to activate, I like to
  ;; put `orderless' at the end of my `completion-styles'.  Like this:
  (setq completion-styles
	'(basic substring initials flex partial-completion orderless))
  (setq completion-category-overrides
	'((file (styles . (basic partial-completion orderless))))))

(use-package tempel
  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert))
  :init
  ;; (defun tempel-setup-capf ()
  ;;   ;; Add the Tempel Capf to `completion-at-point-functions'.
  ;;   ;; `tempel-expand' only triggers on exact matches. Alternatively use
  ;;   ;; `tempel-complete' if you want to see all matches, but then you
  ;;   ;; should also configure `tempel-trigger-prefix', such that Tempel
  ;;   ;; does not trigger too often when you don't expect it. NOTE: We add
  ;;   ;; `tempel-expand' *before* the main programming mode Capf, such
  ;;   ;; that it will be tried first.
  ;;   (setq-local completion-at-point-functions
  ;;               (cons #'tempel-expand
  ;;                     completion-at-point-functions)))
  (setq tempel-path (expand-file-name "templates" user-emacs-directory))
  ;; (add-hook 'conf-mode-hook 'tempel-setup-capf)
  ;; (add-hook 'prog-mode-hook 'tempel-setup-capf)
  ;; (add-hook 'text-mode-hook 'tempel-setup-capf)
  )

(use-package tempel-collection
  :after tempel)

(provide 'config-completion)
;;; config-completion.el ends here
