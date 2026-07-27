;;; programming-nix.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Nix configuration
;;; Code:
(use-package nix-ts-mode
  :if *nix*
  :mode ("\\.nix\\'" "\\.nix.in\\'"))

(use-package nix-drv-mode
  :if *nix*
  :after nix-mode
  :mode "\\.drv\\'")

(use-package nix-shell
  :if *nix*
  :after nix-mode
  :commands (nix-shell-unpack nix-shell-configure nix-shell-build))

(use-package nixpkgs-fmt
  :if *nix*
  :after nix-mode
  :config
  (add-hook 'nix-mode-hook 'nixpkgs-fmt-on-save-mode))

(provide 'programming-nix)
;;; programming-nix.el ends here
