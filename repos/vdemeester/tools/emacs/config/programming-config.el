;;; programming-config.el --- -*- lexical-binding: t -*-
;;; Commentary:
;;; Configuration files mode configuration
;;; Code:

(defconst src-dir "~/src/"
  "Where all my sources are.")
(set-register ?s `(file . ,src-dir))

(use-package devdocs
  :bind (("C-h D" . devdocs-lookup)))

;; TODO: copilot and copilot-chat

;; (use-package highlight-indentation
;;   :hook ((yaml-ts-mode . highlight-indentation-mode)
;;          (yaml-ts-mode . highlight-indentation-current-column-mode)))

(use-package yaml-ts-mode
  :mode "\\.ya?ml\\'"
  :hook ((yaml-ts-mode . display-line-numbers-mode)))

(use-package conf-mode
  :mode ("\\.to?ml\\'" . conf-toml-mode))

(use-package adoc-mode
  :mode ("\\.adoc\\'" . conf-toml-mode))

(defun repeatize (keymap)
  "Add `repeat-mode' support to a KEYMAP."
  (map-keymap
   (lambda (_key cmd)
     (when (symbolp cmd)
       (put cmd 'repeat-map keymap)))
   (symbol-value keymap)))

(defvar flymake-repeat-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") 'flymake-goto-next-error)
    (define-key map (kbd "p") 'flymake-goto-prev-error)
    (define-key map (kbd "f") 'attrap-flymake)
    (define-key map (kbd "M-n") 'flymake-goto-next-error)
    (define-key map (kbd "M-p") 'flymake-goto-prev-error)
    map))

(use-package flymake
  :defer t
  :bind
  (("C-c f e" . flymake-show-project-diagnostics))
  (:map flymake-mode-map
        ("M-n" . flymake-goto-next-error)
        ("M-p" . flymake-goto-prev-error))
  (
   :map flymake-diagnostics-buffer-mode-map
   ("p" .
    (lambda()(interactive)
      (previous-line)
      (save-excursion
        (flymake-show-diagnostic(point)))))
   ("n" .
    (lambda()(interactive)
      (next-line)
      (save-excursion
        (flymake-show-diagnostic(point)))))
   (
    :map flymake-project-diagnostics-mode-map
    ("p" .
     (lambda()(interactive)
       (previous-line)
       (save-excursion
         (flymake-show-diagnostic(point)))))
    ("n" .
     (lambda()(interactive)
       (next-line)
       (save-excursion
         (flymake-show-diagnostic(point)))))))
  :config
  (repeatize 'flymake-repeat-map)
  :hook
  ;; (prog-mode . flyspell-prog-mode) rebind flyspell-auto-correct-previous-word
  (prog-mode . flymake-mode))

(defun my-gotest-get-current-test()
  "Get the current test name, if we have a subtest (starting with name) then use it."
  (interactive)
  (require 'which-func)
  (let ((subtest (when-let* ((subtest
                              (progn
                                (save-excursion
                                  (goto-char (line-beginning-position))
                                  (re-search-forward "name:[[:blank:]]*\"\\([^\"]*\\)\"" (line-end-position) t)))))
                   (if subtest
                       (shell-quote-argument (replace-regexp-in-string " " "_" (match-string-no-properties 1))))))
        (gotest (when-let* ((test-name (which-function)))
                  (if test-name test-name
                    (error "No test selected")))))
    (concat (format "^%s%s$" gotest (if subtest (concat "/" subtest) "")))))

(use-package dape
  :commands (my-dape-go-test-at-point)
  :after go-ts-mode
  :bind
  (:map go-ts-mode-map
        ("<f5>" . (lambda()(interactive)
                    (if (dape--live-connections)
                        (call-interactively 'dape-continue)
                      (call-interactively 'dape))))
        ("S-<f5>"   . dape-stop)
        ("C-S-<f5>" . dape-restart)
        ("<f9>"     . dape-breakpoint-toggle)
        ("<f10>"    . dape-next)
        ("<f11>"    . dape-step-in)
        ("S-<f11>"    . dape-step-out))
  :hook
  (go-ts-mode . (lambda()
                  (interactive)
                  (if (string-suffix-p "_test.go"  (buffer-name))
                      (setq-local dape-command '(delve-unit-test)))))
  :config
  (defun my-dape-go-test-at-point ()
    (interactive)
    (dape (dape--config-eval-1
           `(modes (go-mode go-ts-mode)
                   ensure dape-ensure-command
                   fn dape-config-autoport
                   command "dlv"
                   command-args ("dap" "--listen" "127.0.0.1::autoport")
                   command-cwd dape-cwd-fn
                   port :autoport
                   :type "debug"
                   :request "launch"
                   :mode "test"
                   :cwd dape-cwd-fn
                   :program (lambda () (concat "./" (file-relative-name default-directory (funcall dape-cwd-fn))))
                   :args (lambda ()
                           (when-let* ((test-name (my-gotest-get-current-test)))
                             (if test-name `["-test.run" ,test-name]
                               (error "No test selected")))))))))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :hook ((markdown-mode . visual-line-mode)
	 (gfm-mode . visual-line-mode)))

(use-package orgalist
  :commands (orgalist-mode)
  :hook ((markdown-mode . orgalist-mode)
	 (gfm-mode . orgalist-mode)))

(use-package copilot
  :hook
  (prog-mode . copilot-mode)
  (markdown-mode . copilot-mode)
  (text-mode . copilot-mode)
  (log-edit-mode . copilot-mode)
  (vc-git-log-edit-mode . copilot-mode)
  :bind
  (:map copilot-completion-map
        ("C-g" . copilot-clear-overlay)
        ("C-j" . copilot-next-completion)
        ("C-k" . copilot-previous-completion)
        ("M-RET" . copilot-accept-completion)
        ("C-f" . copilot-accept-completion)
        ("C-l" . copilot-panel-complete))
  :custom
  (copilot-idle-delay 1)
  (copilot-max-char -1)
  (copile-indent-offset-warning-disable t))


(provide 'programming-config)
;;; programming-config.el ends here
