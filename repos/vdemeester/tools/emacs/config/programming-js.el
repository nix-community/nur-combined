;;; programming-js.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Javascript and Typescript programming language configuration
;;; Code:

(use-package js2-mode
  :hook
  (js2-mode . js-ts-mode-hook))

(use-package typescript-mode
  :hook
  (typescript-mode . typescript-ts-mode-hook))

(use-package typescript-ts-mode
  :mode (("\\.ts\\'" . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode)))

(use-package json-mode
  :hook
  (json-mode . json-ts-mode-hook))
  
(provide 'programming-js)
;;; programming-js.el ends here
