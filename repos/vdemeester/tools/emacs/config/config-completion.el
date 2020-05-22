;;; config-completion.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Setup completion framework
;;; Code

;; UseMinibuffer
(use-package minibuffer
  :unless noninteractive
  :config
  (setq completion-cycle-threshold 3)
  (setq completion-flex-nospace nil)
  (setq completion-pcm-complete-word-inserts-delimiters t)
  (setq completion-pcm-word-delimiters "-_./:| ")
  ;; NOTE: flex completion is introduced in Emacs 27
  (setq completion-show-help nil)
  (setq completion-styles '(partial-completion substring initials flex))
  (setq completion-category-overrides
        '((file (styles initials basic))
          (buffer (styles initials basic))
          (info-menu (styles basic))))
  (setq completions-format 'vertical)   ; *Completions* buffer
  (setq enable-recursive-minibuffers t)
  (setq read-answer-short t)
  (setq read-buffer-completion-ignore-case t)
  (setq read-file-name-completion-ignore-case t)
  (setq resize-mini-windows t)

  (file-name-shadow-mode 1)
  (minibuffer-depth-indicate-mode 1)
  (minibuffer-electric-default-mode 1)

  (defun vde/focus-minibuffer ()
    "Focus the active minibuffer.

Bind this to `completion-list-mode-map' to M-v to easily jump
between the list of candidates present in the \\*Completions\\*
buffer and the minibuffer (because by default M-v switches to the
completions if invoked from inside the minibuffer."
    (interactive)
    (let ((mini (active-minibuffer-window)))
      (when mini
        (select-window mini))))

  (defun vde/focus-minibuffer-or-completions ()
    "Focus the active minibuffer or the \\*Completions\\*.

If both the minibuffer and the Completions are present, this
command will first move per invocation to the former, then the
latter, and then continue to switch between the two.

The continuous switch is essentially the same as running
`vde/focus-minibuffer' and `switch-to-completions' in
succession."
    (interactive)
    (let* ((mini (active-minibuffer-window))
           (completions (get-buffer-window "*Completions*")))
      (cond ((and mini
                  (not (minibufferp)))
             (select-window mini nil))
            ((and completions
                  (not (eq (selected-window)
                           completions)))
             (select-window completions nil)))))

  ;; Technically, this is not specific to the minibuffer, but I define
  ;; it here so that you can see how it is also used from inside the
  ;; "Completions" buffer
  (defun vde/describe-symbol-at-point (&optional arg)
    "Get help (documentation) for the symbol at point.

With a prefix argument, switch to the *Help* window.  If that is
already focused, switch to the most recently used window
instead."
    (interactive "P")
    (let ((symbol (symbol-at-point)))
      (when symbol
        (describe-symbol symbol)))
    (when current-prefix-arg
      (let ((help (get-buffer-window "*Help*")))
        (when help
          (if (not (eq (selected-window) help))
              (select-window help)
            (select-window (get-mru-window)))))))

  ;; Defines, among others, aliases for common actions to Super-KEY.
  ;; Normally these should go in individual package declarations, but
  ;; their grouping here makes things easier to understand.
  :bind (("M-v" . vde/focus-minibuffer-or-completions)
         :map completion-list-mode-map
         ("h" . vde/describe-symbol-at-point)
         ("n" . next-line)
         ("p" . previous-line)
         ("f" . next-completion)
         ("b" . previous-completion)
         ("M-v" . vde/focus-minibuffer)))
;; -UseMinibuffer

;; UseIComplete
(use-package icomplete
  :demand
  :unless noninteractive
  :after minibuffer                     ; Read that section as well
  :config
  (setq icomplete-delay-completions-threshold 0)
  (setq icomplete-max-delay-chars 0)
  (setq icomplete-compute-delay 0)
  (setq icomplete-show-matches-on-no-input t)
  (setq icomplete-hide-common-prefix nil)
  (setq icomplete-prospects-height 1)
  (setq icomplete-separator " · ")      ; mid dot, not full stop
  (setq icomplete-in-buffer nil)
  (setq icomplete-with-completion-tables t)

  (fido-mode -1)                        ; Emacs 27.1
  (icomplete-mode 1)

  (defun vde/icomplete-force-complete-and-exit ()
    "Complete the current `icomplete' match and exit the minibuffer.

Contrary to `icomplete-force-complete-and-exit', this will
confirm your choice without complaining about incomplete matches.

Those incomplete matches can block you from performing legitimate
actions, such as defining a new tag in an `org-capture' prompt.

In my testing, this is necessary when the variable
`icomplete-with-completion-tables' is non-nil, because then
`icomplete' will be activated practically everywhere it can."
    (interactive)
    (icomplete-force-complete)
    (exit-minibuffer))

  (defun vde/icomplete-kill-ring-save (&optional arg)
    "Expand and save current `icomplete' match to the kill ring.

With a prefix argument, insert the match to the point in the
current buffer and switch focus back to the minibuffer."
    (interactive "*P")
    (when (and (minibufferp)
               (bound-and-true-p icomplete-mode))
      (icomplete-force-complete)
      (kill-new (field-string-no-properties))
      (when current-prefix-arg
        (kill-new (field-string-no-properties))
        (select-window (get-mru-window))
        (insert (car kill-ring))
        (vde/focus-minibuffer))))

  (defun vde/icomplete-toggle-completion-styles (&optional arg)
    "Toggle between flex and prefix matching.

With pregix ARG use basic completion instead.  These styles are
described in `completion-styles-alist'.

Bind this function in `icomplete-minibuffer-map'."
    (interactive "*P")
    (when (and (minibufferp)
               (bound-and-true-p icomplete-mode))
      (let* ((completion-styles-original completion-styles)
             (basic '(emacs22 basic))
             (flex '(flex initials substring partial-completion))
             (prefix '(partial-completion substring initials flex)))
        (if current-prefix-arg
            (progn
              (setq-local completion-styles basic)
              (message "%s" (propertize "Prioritising BASIC matching" 'face 'highlight)))
          (if (not (eq (car completion-styles) 'flex))
              (progn
                (setq-local completion-styles flex)
                (message "%s" (propertize "Prioritising FLEX matching" 'face 'highlight)))
            (setq-local completion-styles prefix)
            (message "%s" (propertize "Prioritising PREFIX matching" 'face 'highlight)))))))

  (defun vde/switch-buffer (arg)
    "Custom switch to buffer.
With universal argument ARG or when not in project, rely on
`switch-to-buffer'.
Otherwise, use `projectile-switch-to-project'."
    (interactive "P")
    (if (or arg (not (projectile-project-p)))
        (call-interactively 'switch-to-buffer)
      (projectile-switch-to-buffer)))

  :bind (("C-x b" . vde/switch-buffer)
         ("C-x B" . switch-to-buffer)
         :map icomplete-minibuffer-map
         ("C-m" . minibuffer-complete-and-exit) ; force current input
         ("C-n" . icomplete-forward-completions)
         ("<right>" . icomplete-forward-completions)
         ("<down>" . icomplete-forward-completions)
         ("C-p" . icomplete-backward-completions)
         ("<left>" . icomplete-backward-completions)
         ("<up>" . icomplete-backward-completions)
         ("<return>" . vde/icomplete-force-complete-and-exit)
         ("M-o w" . vde/icomplete-kill-ring-save)
         ("M-o i" . (lambda ()
                      (interactive)
                      (let ((current-prefix-arg t))
                        (vde/icomplete-kill-ring-save))))
         ("C-M-," . vde/icomplete-toggle-completion-styles)
         ("C-M-." . (lambda ()
                      (interactive)
                      (let ((current-prefix-arg t))
                        (vde/icomplete-toggle-completion-styles))))))
;; -UseIComplete

;; UseCompany
(use-package company
  :unless noninteractive
  :hook ((prog-mode . company-mode))
  :commands (global-company-mode company-mode company-indent-or-complete-common)
  :bind (("M-/" . hippie-expand)
         :map company-active-map
         ("C-d" . company-show-doc-buffer)
         ("C-l" . company-show-location)
         ("C-t" . company-select-next)
         ("C-s" . company-select-previous)
         ("C-<up>" . company-select-next)
         ("C-<down>" . company-select-previous)
         ("C-r" . company-complete-selection)
         ("TAB" . company-complete-common-or-cycle))
  :config
  (defun company-complete-common-or-selected ()
    "Insert the common part, or if none, complete using selection."
    (interactive)
    (when (company-manual-begin)
      (if (not (equal company-common company-prefix))
          (company--insert-candidate company-common)
        (company-complete-selection))))
  (setq-default company-idle-delay 0.2
                company-selection-wrap-around t
                company-minimum-prefix-length 2
                company-require-match nil
                company-dabbrev-ignore-case nil
                company-dabbrev-downcase nil
                company-show-numbers t
                company-tooltip-align-annotations t)
  (setq company-backends
        '(company-capf
          company-files
          (company-dabbrev-code
           company-gtags
           company-etags)
          company-dabbrev
          company-keywords))

  ;; We don't want completion to prevent us from actually navigating the code
  (define-key company-active-map (kbd "<return>") nil)
  (define-key company-active-map (kbd "RET") nil)
  (define-key company-active-map (kbd "C-p") nil)
  (define-key company-active-map (kbd "C-n") nil))

;; FIXME(vdemeester) Do this in programming-*.el
;; Add company-css to css-mode company-backends
;; (setq-local company-backends (append '(company-css) company-backends))
;; Same for clang, cmake or xcode, elisp

(use-package company-emoji
  :unless noninteractive
  :hook ((markdown-mode . my-company-emoji))
  :config
  (defun my-company-emoji ()
    (set (make-local-variable 'company-backends) '(company-emoji))
    (company-mode t)))

;; -UseCompany

(provide 'config-completion)
;;; config-completion.el ends here
