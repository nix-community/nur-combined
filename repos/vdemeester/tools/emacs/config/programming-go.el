;;; programming-go.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Go programming language configuration
;;; Code:

(declare-function project-root "project")
(declare-function project-current "project")
(declare-function vde-project--project-root-or-default-directory "proj-func")
(declare-function go-test--get-current-file-tests "gotest")

(use-package gotest
  :commands (my-gotest-maybe-ts-run go-test--get-current-test-info go-test--get-current-file-tests)
  :after go-ts-mode
  :custom
  (go-test-verbose t)
  :hook
  (go-test-mode . (lambda () (pop-to-buffer (get-buffer "*Go Test*"))))
  (go-mode . (lambda ()(interactive) (setq go-run-args "-v")))
  (go-ts-mode . (lambda ()(interactive) (setq go-run-args "-v")))
  :config
  (defun my-go-test-current-project()
    (interactive)
    (let ((default-directory (project-root (project-current t))))
      (go-test-current-project)))
  (defun my-gotest-maybe-ts-run()
    (interactive)
    (let ((testrunname)
          (gotest (cadr (go-test--get-current-test-info))))
      (save-excursion
        (goto-char (line-beginning-position))
        (re-search-forward "name:[[:blank:]]*\"\\([^\"]*\\)\"" (line-end-position) t))
      (setq testrunname (match-string-no-properties 1))
      (if testrunname
          (setq gotest (format "%s/%s" gotest (shell-quote-argument
                                               (replace-regexp-in-string " " "_" testrunname)))))
      (go-test--go-test (concat "-run " gotest "\\$ .")))))

(defun go-mode-p ()
  "Return non-nil value when the major mode is `go-mode' or `go-ts-mode'."
  (memq major-mode '(go-ts-mode go-mode)))

;; TODO (defun run-command-recipe-ko ())

(defun run-command-recipe-go ()
  "Go `run-command' recipes."
  (when (buffer-file-name) ;; no buffer-file-name means virtual buffer (dired, …)
    
    (let* ((dir (vde-project--project-root-or-default-directory))
	   (package (file-name-directory (concat "./" (file-relative-name (buffer-file-name) dir)))))
      (when (or (go-mode-p) (file-exists-p (expand-file-name "go.mod" dir)))
	(append
	 (and (buffer-file-name) (go-mode-p)
	      (list
	       (list :command-name "gofumpt"
		     :command-line (concat "gofumpt -extra -w " (buffer-file-name))
		     :working-dir dir
		     :display "gofumpt (reformat) file")
	       (list :command-name "go-fmt"
		     :command-line (concat "go fmt " (buffer-file-name))
		     :working-dir dir
		     :display "gofmt (reformat) file")
	       (list :command-name "go-run"
		     :command-line (concat "go run " (buffer-file-name))
		     :working-dir dir
		     :display "Compile, execute file")))
	 (and (string-suffix-p "_test.go" buffer-file-name) (go-mode-p)
	      (list
	       (let ((runArgs (go-test--get-current-file-tests)))
		 ;; go test current test
		 ;; go test current file
		 (list :command-name "go-test-file"
		       :command-line (concat "go test -v " package " -run " (shell-quote-argument runArgs))
		       :working-dir dir
		       :display (concat "Test file " (concat "./"(file-relative-name (buffer-file-name) dir)))
		       :runner 'run-command-runner-compile)
		 )))
	 ;; TODO: handle test file as well
	 (list
	  (list :command-name "go-build-project"
		:command-line "go build -v ./..."
		:working-dir dir
		:display "compile package and dependencies"
		:runner 'run-command-runner-compile)
	  (list :command-name "go-test-project"
		:command-line "go test ./..."
		:working-dir dir
		:display "test all"
		:runner 'run-command-runner-compile)
	  (list :command-name "go-test-package"
		:command-line (concat "go test -v " package)
		:working-dir dir
		:display (concat "Test package " package)
		:runner 'run-command-runner-compile)))))))

(with-eval-after-load 'run-command
  (add-to-list 'run-command-recipes 'run-command-recipe-go))

(use-package go-ts-mode
  :mode (("\\.go$" . go-ts-mode)
         ("\\.go" . go-ts-mode)
         ("\\.go\\'" . go-ts-mode)))

(provide 'programming-go)
;;; programming-go.el ends here
