;;; config-keybindings.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Key binding specific configuration
;;; Code:

;; Disable C-x C-n to avoid the disabled command buffer
(unbind-key "C-x C-n" global-map)

;; Remap dynamic-abbrev to hippie-expand
;; See https://www.masteringemacs.org/article/text-expansion-hippie-expand
(global-set-key [remap dabbrev-expand] 'hippie-expand)


;; 
(provide 'config-keybindings)
;;; config-keybindings.el ends here
