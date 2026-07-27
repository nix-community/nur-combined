;;; project-x.el --- Extra convenience features for project.el -*- lexical-binding: t -*-

;; Copyright (C) 2021  Karthik Chikmagalur

;; Author: Karthik Chikmagalur <karthik.chikmagalur@gmail.com>
;; URL: https://github.com/karthink/project-x
;; Version: 0.1.5
;; Package-Requires: ((emacs "27.1"))

;; This file is NOT part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; project-x provides some convenience features for project.el:
;; - Recognize any directory with a `.project' file as a project.
;; - Save and restore project files and window configurations across sessions
;;
;; COMMANDS:
;;
;; project-x-window-state-save : Save the window configuration of currently open project buffers
;; project-x-window-state-load : Load a previously saved project window configuration
;;
;; CUSTOMIZATION:
;;
;; `project-x-window-list-file': File to store project window configurations
;; `project-x-local-identifier': String matched against file names to decide if a
;; directory is a project
;; `project-x-save-interval': Interval in seconds between autosaves of the
;; current project.
;;
;; by Karthik Chikmagalur
;; <karthik.chikmagalur@gmail.com>

;;; Code:

(require 'project)
(eval-when-compile (require 'subr-x))
(eval-when-compile (require 'seq))
(defvar project-prefix-map)
(defvar project-switch-commands)
(declare-function project-prompt-project-dir "project")
(declare-function project--buffer-list "project")
(declare-function project-buffers "project")

(defgroup project-x nil
  "Convenience features for the Project library."
  :group 'project)

;; Persistent project sessions
;; -------------------------------------
(defcustom project-x-window-list-file
  (locate-user-emacs-file "project-window-list")
  "File in which to save project window configurations by default."
  :type 'file
  :group 'project-x)

(defcustom project-x-save-interval nil
  "Saves the current project state with this interval.

When set to nil auto-save is disabled."
  :type '(choice (const :tag "Disabled" nil)
                 integer)
  :group 'project-x)

(defvar project-x-window-alist nil
  "Alist of window configurations associated with known projects.")

(defvar project-x-save-timer nil
  "Timer for auto-saving project state.")

(defun project-x--window-state-write (&optional file)
  "Write project window states to `project-x-window-list-file'.
If FILE is specified, write to it instead."
  (when project-x-window-alist
    (require 'pp)
    (unless file (make-directory (file-name-directory project-x-window-list-file) t))
    (with-temp-file (or file project-x-window-list-file)
      (insert ";;; -*- lisp-data -*-\n")
      (let ((print-level nil) (print-length nil))
        (pp project-x-window-alist (current-buffer))))
    (message (format "Wrote project window state to %s" project-x-window-list-file))))

(defun project-x--window-state-read (&optional file)
  "Read project window states from `project-x-window-list-file'.
If FILE is specified, read from it instead."
  (and (or file
           (file-exists-p project-x-window-list-file))
       (with-temp-buffer
         (insert-file-contents (or file project-x-window-list-file))
         (condition-case nil
             (if-let ((win-state-alist (read (current-buffer))))
                 (setq project-x-window-alist win-state-alist)
               (message (format "Could not read %s" project-x-window-list-file)))
           (error (message (format "Could not read %s" project-x-window-list-file)))))))

(defun project-x-window-state-save (&optional arg)
  "Save current window state of project.
With optional prefix argument ARG, query for project."
  (interactive "P")
  (when-let* ((dir (cond (arg (project-prompt-project-dir))
                         ((project-current)
                          (project-root (project-current)))))
              (default-directory dir))
    (unless project-x-window-alist (project-x--window-state-read))
    (let ((file-list))
      ;; Collect file-list of all the open project buffers
      (dolist (buf
               (funcall (if (fboundp 'project--buffers-list)
                            #'project--buffers-list
                          #'project-buffers)
                        (project-current))
               file-list)
        (if-let ((file-name (or (buffer-file-name buf)
                                (with-current-buffer buf
                                  (and (derived-mode-p 'dired-mode)
                                       dired-directory)))))
            (push file-name file-list)))
      (setf (alist-get dir project-x-window-alist nil nil 'equal)
            (list (cons 'files file-list)
                  (cons 'windows (window-state-get nil t)))))
    (message (format "Saved project state for %s" dir))))

(defun project-x-window-state-load (dir)
  "Load the saved window state for project with directory DIR.
If DIR is unspecified query the user for a project instead."
  (interactive (list (project-prompt-project-dir)))
  (unless project-x-window-alist (project-x--window-state-read))
  (if-let* ((project-x-window-alist)
            (project-state (alist-get dir project-x-window-alist
                                      nil nil 'equal)))
      (let ((file-list (alist-get 'files project-state))
            (window-config (alist-get 'windows project-state)))
        (dolist (file-name file-list nil)
          (find-file file-name))
        (window-state-put window-config nil 'safe)
        (message (format "Restored project state for %s" dir)))
    (message (format "No saved window state for project %s" dir))))

(defun project-x-windows ()
  "Restore the last saved window state of the chosen project."
  (interactive)
  (project-x-window-state-load (project-root (project-current))))

;; Recognize directories as projects by defining a new project backend `local'
;; -------------------------------------
(defcustom project-x-local-identifier ".project"
  "Filename(s) that identifies a directory as a project.

You can specify a single filename or a list of names."
  :type '(choice (string :tag "Single file")
                 (repeat (string :tag "Filename")))
  :group 'project-x)

(cl-defmethod project-root ((project (head local)))
  "Return root directory of current PROJECT."
  (cdr project))

(defun project-x-try-local (dir)
  "Determine if DIR is a non-VC project.
DIR must include a .project file to be considered a project."
  (if-let ((root (if (listp project-x-local-identifier)
                     (seq-some (lambda (n)
                                 (locate-dominating-file dir n))
                               project-x-local-identifier)
                   (locate-dominating-file dir project-x-local-identifier))))
      (cons 'local root)))

;;;###autoload
(define-minor-mode project-x-mode
  "Minor mode to enable extra convenience features for project.el.
When enabled, save and load project window states.
Recognize any directory that contains (or whose parent
contains) a special file as a project."
  :global t
  :version "0.10"
  :lighter ""
  :group 'project-x
  (if project-x-mode
      ;;Turning the mode ON
      (progn
        (add-hook 'project-find-functions 'project-x-try-local 90)
        (add-hook 'kill-emacs-hook 'project-x--window-state-write)
        (project-x--window-state-read)
        (define-key project-prefix-map (kbd "w") 'project-x-window-state-save)
        (define-key project-prefix-map (kbd "j") 'project-x-window-state-load)
        (if (listp project-switch-commands)
            (add-to-list 'project-switch-commands
                         '(?j "Restore windows" project-x-windows) t)
          (message "`project-switch-commands` is not a list, not adding 'restore windows' command"))
        (when project-x-save-interval
          (setq project-x-save-timer
                (run-with-timer 0 (max project-x-save-interval 5)
                                #'project-x-window-state-save))))
    (remove-hook 'project-find-functions 'project-x-try-local 90)
    (remove-hook 'kill-emacs-hook 'project-x--window-state-write)
    (define-key project-prefix-map (kbd "w") nil)
    (define-key project-prefix-map (kbd "j") nil)
    (when (listp project-switch-commands)
      (delete '(?j "Restore windows" project-x-windows) project-switch-commands))
    (when (timerp project-x-save-timer)
      (cancel-timer project-x-save-timer))))

(provide 'project-x)
;;; project-x.el ends here
