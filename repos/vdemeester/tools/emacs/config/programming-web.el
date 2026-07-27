;;; programming-web.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Programming the Web related configuration
;;; Code:

(use-package web-mode
  :commands (web-mode)
  :mode
  ("\\.html\\'" . web-mode)
  ("\\.phtml\\'" . web-mode)
  ("\\.[agj]sp\\'" . web-mode)
  ("\\.as[cp]x\\'" . web-mode)
  ("\\.erb\\'" . web-mode)
  ("\\.mustache\\'" . web-mode)
  ("\\.djhtml\\'" . web-mode)
  ("\\.jsp\\'" . web-mode)
  ("\\.eex\\'" . web-mode)
  ("\\.tsx\\'" . web-mode)
  :config
  (setq web-mode-attr-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-indent-style 2)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-sql-indent-offset 2)
  (eval-after-load 'smartparens
    (lambda ()
      (setq web-mode-enable-auto-pairing nil)
      (sp-with-modes '(web-mode)
        (sp-local-pair "%" "%"
                       :unless '(sp-in-string-p)
                       :post-handlers '(((lambda (&rest _ignored)
                                           (just-one-space)
                                           (save-excursion (insert " ")))
                                         "SPC" "=" "#")))
        (sp-local-tag "%" "<% "  " %>")
        (sp-local-tag "=" "<%= " " %>")
        (sp-local-tag "#" "<%# " " %>")))))

(provide 'programming-web)
;;; programming-web.el ends here
