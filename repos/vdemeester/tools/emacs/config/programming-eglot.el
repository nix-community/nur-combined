;;; programming-eglot.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Eglot configuration
;;; Code:
(use-package eglot
  :bind
  (:map eglot-mode-map
        ("C-c e a" . eglot-code-actions)
        ("C-c e r" . eglot-reconnect)
        ("<f2>" . eglot-rename)
        ("C-c e ?" . eldoc-print-current-symbol-info))
  :config
  (add-to-list 'eglot-ignored-server-capabilities :documentHighlightProvider)
  (add-to-list 'eglot-server-programs `(json-mode  "vscode-json-language-server" "--stdio"))
  (setq-default eglot-workspace-configuration
		'(:gopls (:usePlaceholders t)))
  (setq-default
   eglot-workspace-configuration
   '((:gopls . ((gofumpt . t)))))
  :hook
  (before-save . gofmt-before-save)
  (before-save . eglot-format-buffer)
  (rust-mode . eglot-ensure)
  (rust-ts-mode . eglot-ensure)
  (sh-script-mode . eglot-ensure)
  (python-mode . eglot-ensure)
  (json-mode . eglot-ensure)
  (yaml-mode . eglot-ensure)
  (c-mode . eglot-ensure)
  (cc-mode . eglot-ensure)
  (go-mode . eglot-ensure)
  (go-ts-mode . eglot-ensure)
  (js-mode . eglot-ensure)
  (js2-mode . eglot-ensure)
  (typescript-mode . eglot-ensure)
  (typescript-ts-mode . eglot-ensure)
  :custom
  rustic-lsp-client 'eglot)

(use-package eldoc-box
  :hook
  (eglot-managed-mode . eldoc-box-hover-mode)
  :custom
  (eldoc-box-max-pixel-width 1024))


(provide 'programming-eglot)
;;; programming-eglot.el ends here
