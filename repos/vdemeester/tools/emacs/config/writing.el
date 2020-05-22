;;; writing.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Writing modes configuration
;;; Code:

(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode)
  :config
  (setq markdown-fontify-code-blocks-natively t)

  ;; Don't change font in code blocks
  (set-face-attribute 'markdown-code-face nil
                      :inherit nil)

  ;; Process Markdown with Pandoc, using a custom stylesheet for nice output
  (let ((stylesheet (expand-file-name
                     (locate-user-emacs-file "etc/pandoc.css"))))
    (setq markdown-command
          (mapconcat #'shell-quote-argument
                     `("pandoc" "--toc" "--section-divs"
                       "--css" ,(concat "file://" stylesheet)
                       "--standalone" "-f" "markdown" "-t" "html5")
                     " ")))
  (add-hook 'markdown-mode-hook #'auto-fill-mode))

(provide 'writing)
;;; writing.el ends here
