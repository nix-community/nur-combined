;;; 01-server.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Enable server-mode
;;; Code:

;; UseServer
(use-package server
  :disabled
  :config (or (server-running-p) (server-mode)))
;; -UseServer

;;; 01-server.el ends here
