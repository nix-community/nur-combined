;;; config-buffers.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Buffer related configurations
;;; Code:

(use-package savehist
  :unless noninteractive
  :init
  (setq savehist-file (no-littering-expand-var-file-name "savehist"))
  :config
  (setq-default history-length 10000
                savehist-save-minibuffer-history t
		savehist-delete-duplicates t
                savehist-autosave-interval 180
                savehist-additional-variables '(extended-command-history
                                                search-ring
                                                regexp-search-ring
                                                comint-input-ring
                                                compile-history
                                                last-kbd-macro
                                                shell-command-history
                                                projectile-project-command-history))
  (savehist-mode 1))

(use-package uniquify
  :unless noninteractive
  :config
  (setq-default uniquify-buffer-name-style 'post-forward
                uniquify-separator ":"
                uniquify-ignore-buffers-re "^\\*"
                uniquify-after-kill-buffer-p t))

(use-package ibuffer
  :unless noninteractive
  :commands (ibuffer)
  :bind (("C-x C-b" . ibuffer)
         ([remap list-buffers] . ibuffer))
  :config
  (setq-default ibuffer-expert t
                ibuffer-filter-group-name-face 'font-lock-doc-face
                ibuffer-default-sorting-mode 'filename/process
                ibuffer-use-header-line t
                ibuffer-show-empty-filter-groups nil)
  ;; Use human readable Size column instead of original one
  (define-ibuffer-column size-h
    (:name "Size" :inline t)
    (cond
     ((> (buffer-size) 1000000) (format "%7.1fM" (/ (buffer-size) 1000000.0)))
     ((> (buffer-size) 1000) (format "%7.1fk" (/ (buffer-size) 1000.0)))
     (t (format "%8d" (buffer-size)))))

  ;; (setq ibuffer-formats
  ;;       '((mark modified read-only " "
  ;;               (name 18 18 :left :elide)
  ;;               " "
  ;;               (size-h 9 -1 :right)
  ;;               " "
  ;;               (mode 16 16 :left :elide)
  ;;               " "
  ;;               filename-and-process)
  ;;         (mark modified read-only " "
  ;;               (name 18 18 :left :elide)
  ;;               " "
  ;;               (size 9 -1 :right)
  ;;               " "
  ;;               (mode 16 16 :left :elide)
  ;;               " "
  ;;               (vc-status 16 16 :left)
  ;;               " "
  ;;               filename-and-process)))
  )

(use-package ibuffer-vc
  :unless noninteractive
  :commands (ibuffer-vc-set-filter-groups-by-vc-root)
  :hook (ibuffer . (lambda ()
                     (ibuffer-vc-set-filter-groups-by-vc-root)
                     (unless (eq ibuffer-sorting-mode 'filename/process)
                       (ibuffer-do-sort-by-filename/process)))))

(unless noninteractive
  (require 'popper)
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
	  helpful-mode
          compilation-mode
	  flymake-diagnostics-buffer-mode
	  flymake-project-diagnostics-mode
	  Man-mode
	  woman-mode))
  (global-set-key (kbd "C-`") 'popper-toggle)
  (global-set-key (kbd "M-`") 'popper-cycle)
  (global-set-key (kbd "C-M-`") 'popper-toggle-type)
  (popper-mode +1)

  ;; For echo-area hints
  (require 'popper-echo)
  (popper-echo-mode +1))

(use-package goto-addr
  :hook ((text-mode . goto-address-mode)
         (prog-mode . goto-address-prog-mode)))

(provide 'config-buffers)
;;; config-buffers.el ends here
