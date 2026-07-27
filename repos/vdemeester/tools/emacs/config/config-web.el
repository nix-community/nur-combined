;;; config-web.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Web related configuration, notably the built-in web browser.
;;; Code:

;; (use-package shr
;;   :config
;;   (setq shr-use-fonts nil)
;;   (setq shr-use-colors nil)
;;   (setq shr-bullet "• ")
;;   (setq shr-folding-mode t)
;; 
;;   (setq shr-max-image-proportion 0.7)
;;   (setq shr-image-animate nil)
;;   (setq shr-width (current-fill-column)))
;; 
;; (use-package shr-tag-pre-highlight
;;   :after shr
;;   :config
;;   (add-to-list 'shr-external-rendering-functions
;;                '(pre . shr-tag-pre-highlight))
;;   (when (version< emacs-version "26")
;;     (with-eval-after-load 'eww
;;       (advice-add 'eww-display-html :around
;;                   'eww-display-html--override-shr-external-rendering-functions))))
;; 
;; (use-package eww
;;   :commands (eww
;;              eww-browse-url
;;              eww-search-words
;;              eww-open-in-new-buffer
;;              eww-open-file
;;              vde/eww-visit-history)
;;   :config
;;   (setq eww-restore-desktop nil)
;;   (setq eww-desktop-remove-duplicates t)
;;   (setq eww-header-line-format "%u")
;;   (setq eww-search-prefix "https://duckduckgo.com/html/?q=")
;;   (setq url-privacy-level '(email agent cookies lastloc))
;;   (setq eww-download-directory "~/desktop/downloads/")
;;   (setq eww-suggest-uris
;;         '(eww-links-at-point
;;           thing-at-point-url-at-point))
;;   (setq eww-bookmarks-directory "~/.emacs.d/eww-bookmarks/")
;;   (setq eww-history-limit 150)
;;   (setq eww-use-external-browser-for-content-type
;;         "\\`\\(video/\\|audio/\\|application/pdf\\)")
;;   (setq eww-browse-url-new-window-is-tab nil)
;;   (setq eww-form-checkbox-selected-symbol "[X]")
;;   (setq eww-form-checkbox-symbol "[ ]")
;; 
;;   ;; eww-view-source
;; 
;;   (defvar vde/eww-mode-global-map
;;     (let ((map (make-sparse-keymap)))
;;       (define-key map "s" 'eww-search-words)
;;       (define-key map "o" 'eww-open-in-new-buffer)
;;       (define-key map "f" 'eww-open-file)
;;       map)
;;     "Key map to scope `eww' bindings for global usage.
;; The idea is to bind this to a prefix sequence, so that its
;; defined keys follow the pattern of <PREFIX> <KEY>.")
;;   :bind-keymap ("C-x w" . vde/eww-mode-global-map)
;;   :bind (:map eww-mode-map
;;               ("n" . next-line)
;;               ("p" . previous-line)
;;               ("f" . forward-char)
;;               ("b" . backward-char)
;;               ("B" . eww-back-url)
;;               ("N" . eww-next-url)
;;               ("P" . eww-previous-url)))

(use-package browse-url
  :after eww
  :config

  (defun browse-url-xdg-desktop-portal (url &rest args)
    "Open URL via a portal backend."
    (dbus-call-method :session
                      "org.freedesktop.portal.Desktop"
                      "/org/freedesktop/portal/desktop"
                      "org.freedesktop.portal.OpenURI"
                      "OpenURI"
                      "" url '(:array :signature "{sv}")))
  (setopt browse-url-browser-function #'browse-url-xdg-desktop-portal)
  ;; (setq browse-url-browser-function #'eww-browse-url)

  ;; (setq browse-url-generic-program "google-chrome-stable")
  (setq browse-url-handlers '(("^https://gitlab.com.*" . browse-url-firefox)
                              ("^https://github.com.*" . browse-url-default-browser)
                              ("^https://issues.redhat.com.*" . browse-url-default-browser)
                              ("^https://.*redhat.com.*" . browse-url-default-browser)
                              ("^https://docs.jboss.org.*" . browse-url-default-browser)
                              (".*" . eww-browse-url))))

(provide 'config-web)
;;; config-web.el ends here
