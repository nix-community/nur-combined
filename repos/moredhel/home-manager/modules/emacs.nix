''
(setq inhibit-startup-screen t)

(require 'package)
(setq package-enable-at-startup nil)
;;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;;(add-to-list 'package-archives '("melpa" . "http://www.mirrorservice.org/sites/melpa.org/packages/"))

(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))


;; non-specific functionality
(setq vc-follow-symlinks t)
(load-theme 'whiteboard)
(remove-hook 'find-file-hooks 'vc-find-file-hook)


;; ----------- Nix ------------------
(defun nix-shell-context (orig-func &rest args)
  "Set a temporary environment with the correct paths to wrap default commands"
  (let* ((nix-path (condition-case nil (nix-exec-path
                                        (nix-find-sandbox
                                         (or  (file-name-directory (or  buffer-file-name "")) "/")))
                     (error nil)))
         (exec-path (or nix-path exec-path)))
    (apply orig-func args)))

;; Functions which need to have their context potentially changed
(advice-add 'executable-find :around #'nix-shell-context)
(advice-add 'rust--format-call :around #'nix-shell-context)

;; ---------- End Nix --------------
;; custom functions & variables

(defun switch-to-scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))

;; this may need to be moved into the helm use-package section.
(defun helm-save-and-paste ()
  (interactive)
  (kill-new (x-get-clipboard))
  (helm-show-kill-ring))

;; move this somewhere more useful...
(global-set-key (kbd "M-p") 'helm-save-and-paste)

;; (use-package solarized-theme
;;   :ensure t
;;   :no-require t
;;   :config
;;   (load-theme 'solarized-dark t))

(use-package magit
  :ensure t
  :config
  (setq
   magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1))

(use-package better-defaults :ensure t)
(use-package better-defaults)

;; custom keybindings
(let ((map (make-sparse-keymap)))
  (define-key map "gs" 'magit-status)
  (define-key map "/" 'helm-projectile-ag)
  (define-key map "bs" 'switch-to-scratch)
  ;; bind to Meta-Space
  (define-key global-map (kbd "M-SPC") map))

(use-package evil-leader
  :ensure t
  :config
  (global-evil-leader-mode t)
  (evil-leader/set-leader "<SPC>" "C-")
  (evil-leader/set-key
    ;; toggles
    "tt" 'whitespace-mode

    "q"  'delete-frame
    "bd"  'evil-delete-buffer
    "w"  'save-buffer
    "pb"  'helm-projectile-switch-to-buffer
    "pf" 'projectile-find-file
    "bb"  'helm-buffers-list
    "bs"  'switch-to-scratch
    "oo"  'other-frame
    "kb" 'kill-buffer
    "gs" 'magit-status
    "/"  'helm-projectile-ag

    ;; org
    "mp" 'my-org-mobile-push
    "mg" 'org-mobile-pull-switch
    "r"  'org-capture
    "cj" 'org-clock-goto
    "cr" 'org-resolve-clocks

    ))
(use-package evil
  :ensure t
  :config
  (evil-mode 1))

(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper))

(use-package find-file-in-project)
(use-package idle-highlight-mode :ensure t)

(use-package paredit
  :ensure t
  :config
  (autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
  (add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
  (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
  (add-hook 'scheme-mode-hook           #'enable-paredit-mode))

(use-package smex
  :ensure t
  :config
  (smex-initialize)
  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command))

(use-package scpaste :ensure t)
(use-package swiper :ensure t)

(use-package helm
  :config
  (helm-mode)
  (global-set-key (kbd "M-x") 'helm-M-x))

(use-package helm-ag
  :ensure t)

(use-package helm-projectile
  :ensure t
  :config
  (setq projectile-completion-system 'helm)
  (helm-projectile-on))

(use-package projectile
  :ensure t
  :config
  (projectile-global-mode))

(use-package company
  :ensure t
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  (add-hook 'racer-mode-hook #'company-mode))

(use-package racer
  :ensure t
  :config
  (add-hook 'rust-mode-hook #'racer-mode)
  (add-hook 'racer-mode-hook #'eldoc-mode)
  (define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
  (setq racer-rust-src-path ""
        racer-cmd "racer"))

;; start the server
;; (server-start)
(global-undo-tree-mode t)

;; language specific configs
(use-package go-mode
  :no-require t)

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))


(use-package yaml-mode
  :ensure t
  :config
  (add-hook 'yaml-mode-hook
            (lambda ()
              (define-key yaml-mode-map "\C-m" 'newline-and-indent))))

(use-package nix-mode
  :no-require t)

(use-package dockerfile-mode
  :no-require t)

(server-start)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default)))
 '(org-agenda-files
   (quote
    ("~/org/journal/20170919.org" "~/org/notes.org" "~/org/life.org" "~/org/life-media.org" "/home/moredhel/org/CS/general.org" "/home/moredhel/org/journal/20170912.org" "/home/moredhel/org/journal/20170913.org" "/home/moredhel/org/journal/20170914.org")))
 '(package-selected-packages
   (quote
    (dr-racket-like-unicode racket-mode general protobuf-mode helm-nixos-options nixos-options nix-buffer org-journal company racer nix-sandbox auto-complete haskell-mode helm-ag helm-projectile projectile go-mode go yaml-mode use-package swiper solarized-theme smex scpaste rust-mode paredit org-mobile-sync org-evil org-bullets notmuch nix-mode markdown-mode magit ido-ubiquitous idle-highlight-mode helm find-file-in-project evil-leader enh-ruby-mode dockerfile-mode better-defaults)))
 '(send-mail-function (quote sendmail-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'narrow-to-page 'disabled nil)
(put 'narrow-to-region 'disabled nil)
''

# Local Variables:
# mode: lisp
# End:
