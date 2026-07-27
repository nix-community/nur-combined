;;; config-org.el --- -*- lexical-binding: t; -*-
;;; Commentary:
;;; Configuration of orgmode.
;;; Code:

(use-package s)
(use-package dash)

(defconst org-directory "~/desktop/org/"
  "org-mode directory, where most of the org-mode file lives")
;; P.A.R.A. setup
(defconst org-inbox-file (expand-file-name "20231120T124316--inbox__inbox.org" org-directory)
  "New stuff collected in this file.")

(defconst org-archive-dir (expand-file-name "archive" org-directory)
  "Directory of archived files.")

(defconst org-projects-dir (expand-file-name "projects" org-directory)
  "Project files directory.")
(defconst org-projects-completed-dir (expand-file-name "projects" org-archive-dir)
  "Directory of completed project files.")
(defconst org-projects-future-file (expand-file-name "20231120T124316--future-projects-incubation__project_future.org" org-projects-dir)
  "Future projects are collected in this file.")

(defconst org-areas-dir (expand-file-name "areas" org-directory)
  "Area files directory.")

(defconst org-resources-dir (expand-file-name "resources" org-directory)
  "Resource files directory.")
(defconst org-resources-articles-dir (expand-file-name "articles" org-resources-dir)
  "Article resource files directory.")
(defconst org-resources-books-dir (expand-file-name "books" org-resources-dir)
  "Book resource files directory.")
(defconst org-people-dir (expand-file-name "people" org-directory)
  "People files directory.")
(defconst org-journal-dir (expand-file-name "journal" org-directory)
  "Journal files directory")

(defconst src-home-dir (expand-file-name "~/src/home" org-directory)
  "Directory of my home monorepository, can contain todos there.")
;; 2024-06-11: Should it be in home ? I've been going back and forth on this
(defconst src-www-dir (expand-file-name "~/src/www" org-directory)
  "Directory of my www repository, can contain todos there.")

(defconst org-babel-library-file (expand-file-name "org_library_of_babel.org" org-directory)
  "Org babel library.")

(set-register ?i `(file . ,org-inbox-file))
(set-register ?f `(file . ,org-projects-future-file))
(set-register ?p `(file . ,org-projects-dir))
(set-register ?a `(file . ,org-areas-dir))
(set-register ?r `(file . ,org-resources-dir))
(set-register ?P `(file . ,org-people-dir))
(set-register ?j `(file . ,org-journal-dir))

(defun vde/agenda-goto-view ()
  "Jump to the task narrowed but in view mode only to get a glance."
  (interactive)
  (org-agenda-goto)
  (org-narrow-to-subtree)
  (view-mode t))

(defun vde/org-mode-hook ()
  "Org-mode hook"
  (setq show-trailing-whitespace t)
  (when (not (eq major-mode 'org-agenda-mode))
    (setq fill-column 90)
    (auto-revert-mode 1)
    (auto-fill-mode 1)
    (org-indent-mode 1)
    (visual-line-mode 1)
    (add-hook 'before-save-hook 'org-update-all-dblocks)
    (add-hook 'auto-save-hook 'org-update-all-dblocks)
    (add-hook 'before-save-hook #'save-and-update-includes nil 'make-it-local)))

(use-package org
  :mode (("\\.org$" . org-mode)
         ("\\.org.draft$" . org-mode))
  :commands (org-agenda org-capture)
  :bind (("C-c o l" . org-store-link)
         ("C-c o r r" . org-refile)
	 ("C-c o r R" . vde/reload-org-refile-targets)
         ("C-c o a a" . org-agenda)
	 ("C-c o a r" . vde/reload-org-agenda-files)
         ("C-c o s" . org-sort)
         ("<f12>" . org-agenda))
  :hook (org-mode . vde/org-mode-hook)
  :custom
  ;; (org-reverse-note-order '((org-inbox-file . t) ;; Insert items on top of inbox
  ;;                           (".*" . nil)))    ;; On any other file, insert at the bottom
  (org-archive-location (concat org-archive-dir "/%s::datetree/"))
  (org-agenda-file-regexp "^[a-zA-Z0-9-_]+.org$")
  (org-use-speed-commands t)
  (org-special-ctrl-a/e t)
  (org-special-ctrl-k t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-ellipsis "…")
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "STARTED(s)" "IN-REVIEW(r)" "|" "DONE(d!)" "CANCELED(c@/!)")
                       (sequence "WAITING(w@/!)" "SOMEDAY(s)" "|" "CANCELED(c@/!)")
                       (sequence "IDEA(i)" "|" "CANCELED(c@/!)")))
  (org-todo-state-tags-triggers '(("CANCELLED" ("CANCELLED" . t))
                                  ("WAITING" ("WAITING" . t))
                                  (done ("WAITING"))
                                  ("TODO" ("WAITING") ("CANCELLED"))
                                  ("NEXT" ("WAITING") ("CANCELLED"))
                                  ("DONE" ("WAITING") ("CANCELLED"))))
  (org-log-done 'time)
  (org-log-redeadline 'time)
  (org-log-reschedule 'time)
  (org-log-into-drawer t)
  (org-refile-use-outline-path 'file)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-list-demote-modify-bullet '(("+" . "-") ("-" . "+")))
  (org-agenda-span 'day)
  (org-agenda-start-on-weekday 1)
  (org-agenda-window-setup 'current-window)
  (org-agenda-skip-scheduled-if-deadline-is-shown t)
  (org-agenda-skip-timestamp-if-deadline-is-shown t)
  (org-agenda-skip-scheduled-if-done nil)
  (org-agenda-current-time-string "")
  (org-agenda-time-grid '((daily) () "" ""))
  ;; ((agenda . " %i %-12:c%?-12t% s")
  ;;  (todo . " %i %-12:c")
  ;;  (tags . " %i %-12:c")
  ;;  (search . " %i %-12:c"))
  ;; (org-agenda-prefix-format "   %i %?-2 t%s")
  (org-agenda-prefix-format '((agenda . " %i %?-12t% s")
   (todo . " %i")
   (tags . " %i")
   (search . " %i")))
  (org-insert-heading-respect-content t)

  (org-goto-interface 'outline-path-completion)
  (org-outline-path-complete-in-steps nil)
  (org-goto-max-level 2)

  (org-agenda-category-icon-alist `(("journal"  ,(list (propertize "📝")))
				    ("project--" ,(list (propertize "💼" )))
				    ("tekton-", (list (propertize "😼")))
				    ("area--"  ,(list (propertize"🏢" )))
				    ("area--home"  ,(list (propertize"🏡" )))
				    ("home"  ,(list (propertize"🏡" )))
				    ("machine" ,(list (propertize "🖥️")))
				    ("website" ,(list (propertize "🌍")))
				    (".*" '(space . (:width (16))))))
;;         (org-agenda-compact-blocks t)
        (org-agenda-sticky t)
;;         (org-agenda-include-diary t)
  :config

  ;; Org Babel configurations
  (when (file-exists-p org-babel-library-file)
    (org-babel-lob-ingest org-babel-library-file))
  (defun vde/org-agenda-files ()
    (apply 'append
		   (mapcar
			(lambda (directory)
			  (directory-files-recursively
			   directory org-agenda-file-regexp))
			`(,org-projects-dir ,org-areas-dir ,org-resources-dir ,org-journal-dir ,src-home-dir ,(expand-file-name "~/src/osp/tasks")))))
  (defun vde/reload-org-agenda-files ()
    "Reload org-agenda-files variables with up-to-date org files"
    (interactive)
    (setq org-agenda-files (vde/org-agenda-files)))
  (defun vde/reload-org-refile-targets ()
    "Reload org-refile-targets variables with up-to-date org files"
    (interactive)
    (setq org-refile-targets (vde/org-refile-targets)))
  (defun vde/org-refile-targets ()
    (append '((org-inbox-file :level . 0))
				   (->>
				    (directory-files org-projects-dir nil ".org$")
				    (--remove (s-starts-with? "." it))
				    (--map (format "%s/%s" org-projects-dir it))
				    (--map `(,it :maxlevel . 3)))
				   (->>
				    (directory-files org-areas-dir nil ".org$")
				    (--remove (s-starts-with? "." it))
				    (--map (format "%s/%s" org-areas-dir it))
				    (--map `(,it :maxlevel . 3)))
				   (->>
				    (directory-files-recursively src-home-dir ".org$")
				    (--remove (s-starts-with? "." it))
				    (--map (format "%s" it))
				    (--map `(,it :maxlevel . 2)))
				   ;; (->>
				   ;;  (directory-files-recursively src-www-dir ".org$")
				   ;;  (--remove (s-starts-with? "." it))
				   ;;  (--map (format "%s" it))
				   ;;  (--map `(,it :maxlevel . 2)))
				   (->>
				    (directory-files-recursively org-resources-dir ".org$")
				    (--remove (s-starts-with? (format "%s/legacy" org-resources-dir) it))
				    (--map (format "%s" it))
				    (--map `(,it :maxlevel . 3)))))
  (setq org-agenda-files (vde/org-agenda-files)
	;; TODO: extract org-refile-targets into a function
	org-refile-targets (vde/org-refile-targets))
  (setq org-agenda-custom-commands
	'(("d" "Daily Agenda"
	   ((agenda ""
		    ((org-agenda-span 'day)
		     (org-deadline-warning-days 5)))
	    (tags-todo "+PRIORITY=\"A\""
		       ((org-agenda-overriding-header "High Priority Tasks")))
	    (todo "NEXT"
		       ((org-agenda-overriding-header "Next Tasks")))))
	  ("i" "Inbox (triage)"
	   ((tags-todo ".*"
		  ((org-agenda-files '("~/desktop/org/20231120T124316--inbox__inbox.org"))
		   (org-agenda-overriding-header "Unprocessed Inbox Item")))))
	  ("u" "Untagged Tasks"
	   ((tags-todo "-{.*}"
		       ((org-agenda-overriding-header "Untagged tasks")))))
	  ("w" "Weekly Review"
	   ((agenda ""
		    ((org-agenda-overriding-header "Completed Tasks")
		     (org-agenda-skip-function '(org-agenda-skip-entry-if 'nottodo 'done))
		     (org-agenda-span 'week)))
	    (agenda ""
		    ((org-agenda-overriding-header "Unfinished Scheduled Tasks")
		     (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
		     (org-agenda-span 'week))))))))

;; Make sure we load org-protocol
(use-package org-protocol
  :after org)

(use-package org-tempo
  :after (org)
  :custom
  (org-structure-template-alist '(("a" . "aside")
				  ("c" . "center")
				  ("C" . "comment")
				  ("e" . "example")
				  ("E" . "export")
				  ("Ea" . "export ascii")
				  ("Eh" . "export html")
				  ("El" . "export latex")
				  ("q" . "quote")
				  ("s" . "src")
				  ("se" . "src emacs-lisp")
				  ("sE" . "src emacs-lisp :results value code :lexical t")
				  ("sg" . "src go")
				  ("sr" . "src rust")
				  ("sp" . "src python")
				  ("v" . "verse"))))

(use-package org-id
  :after org
  :commands contrib/org-id-headlines
  :init
  (defun contrib/org-id-headlines ()
    "Add CUSTOM_ID properties to all headlines in the current
file which do not already have one."
    (interactive)
    (org-map-entries
     (funcall 'contrib/org-get-id (point) 'create)))
  :config
  (setq org-id-link-to-org-use-id
        'create-if-interactive-and-no-custom-id))

(use-package org-modern
  ;; :if window-system
  :custom (org-modern-table nil)
  :hook (org-mode . org-modern-mode))

(use-package org-capture
  :after org
  :commands (org-capture)
  :config

  ;; TODO: refine this, create a function that reset this
  (add-to-list 'org-capture-templates
               `("l" "Link" entry
                 (file ,org-inbox-file)
                 "* %a\n%U\n%?\n%i"
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
	       `("d" "daily entry" entry
		 (file ,(car (denote-journal-extras--entry-today)))
                 "* %a\n%U\n%?\n%i"
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
               `("t" "Tasks"))
  (add-to-list 'org-capture-templates
               `("tt" "New task" entry
                 (file ,org-inbox-file)
                 "* %?\n:PROPERTIES:\n:CREATED:\t%U\n:END:\n\n%i\n\nFrom: %a"
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
               `("tr" "PR Review" entry
                 (file ,org-inbox-file)
                 "* TODO review gh:%^{issue} :review:\n:PROPERTIES:\n:CREATED:%U\n:END:\n\n%i\n%?\nFrom: %a"
                 :empty-lines 1))

  ;; (add-to-list 'org-capture-templates
  ;;              `("m" "Meeting notes" entry
  ;;                (file+datetree ,org-meeting-notes-file)
  ;;                (file ,(concat user-emacs-directory "/etc/orgmode/meeting-notes.org"))))

  (add-to-list 'org-capture-templates
               `("w" "Writing"))
  :bind (("C-c o c" . org-capture)))

(defun vde/dired-notes ()
  "Open a dired buffer with all my notes"
  (interactive)
  (find-dired org-directory "-type f -not -path '*/archive/*'"))

;; Using denote as the "source" of my second brain *in* org-mode.
(use-package denote
  :bind (("C-c n n" . vde/dired-notes)
	 ("C-c n N" . denote)
	 ("C-c n c" . denote-region)
	 ("C-c n N" . denote-type)
	 ("C-c n d" . denote-date)
	 ("C-c n z" . denote-signature)
	 ("C-c n s" . denote-subdirectory)
	 ("C-c n t" . denote-template)
	 ;; Links
	 ("C-c n i" . denote-link)
	 ("C-c n I" . denote-add-links)
	 ("C-c n b" . denote-backlinks)
	 ("C-c n f f" . denote-find-link)
	 ("C-c n f b" . denote-find-backlink)
	 ;; Renaming
	 ("C-c n r" . denote-rename-file)
	 ("C-c n R" . denote-rename-file-using-front-matter)
	 ;; Journal
	 ("C-c n j j" . denote-journal-extras-new-or-existing-entry)
	 ;; Dired
	 (:map dired-mode-map
	       ("C-c C-d C-i" . denote-link-dired-marked-notes)))
  :custom
  (denote-directory org-directory)
  (denote-rename-buffer-format "📝 %t")
  (denote-date-prompt-denote-date-prompt-use-org-read-date t)
  (denote-prompts '(subdirectory title keyword))
  :hook (dired-mode . denote-dired-mode)
  :init
  (require 'denote-rename-buffer)
  (require 'denote-org-extras)
  (require 'denote-journal-extras)
  :config
  (denote-rename-buffer-mode 1)
  (setq denote-journal-extras-directory org-journal-dir
	denote-journal-extras-title-format 'day-date-month-year)
  (with-eval-after-load 'org-capture
  (setq denote-org-capture-specifiers "%l\n%i\n%?")
  (add-to-list 'org-capture-templates
               '("n" "New note (with denote.el)" plain
                 (file denote-last-path)
                 #'denote-org-capture
                 :no-save t
                 :immediate-finish nil
                 :kill-buffer t
                 :jump-to-captured t)))
  (defun vde/org-category-from-buffer ()
    "Get the org category (#+category:) value from the buffer"
  (cond
   ((string-match (format "^%s.*$" org-journal-dir) (buffer-file-name))
    "journal")
   (t
    (denote-sluggify (denote--retrieve-title-or-filename (buffer-file-name) 'org))))))

(use-package consult-notes
  :commands (consult-notes
             consult-notes-search-in-all-notes
	     consult-notes-denote-mode)
  :bind (("C-c n F" . consult-notes)
	 ("C-c n S" . consult-notes-search-in-all-notes))
  :config
  (when (locate-library "denote")
    (consult-notes-denote-mode)))

(use-package orgit)

(use-package ob-async
  :after org
  :commands (ob-async-org-babel-execute-src-block))
(use-package ob-emacs-lisp
  :after org
  :commands (org-babel-execute:emacs-lisp org-babel-execute:elisp))
(use-package ob-go
  :after org
  :commands (org-babel-execute:go))
(use-package ob-python
  :after org
  :commands (org-babel-execute:python))
(use-package ob-shell
  :after org
  :commands (org-babel-execute:ash
             org-babel-execute:bash
             org-babel-execute:csh
             org-babel-execute:dash
             org-babel-execute:fish
             org-babel-execute:ksh
             org-babel-execute:mksh
             org-babel-execute:posh
             org-babel-execute:sh
             org-babel-execute:shell
             org-babel-execute:zsh))
;; my personal
(use-package ol-github
  :after (org))
(use-package ol-gitlab
  :after (org))
(use-package ol-ripgrep
  :after (org))
(use-package ol-rg
  :disabled
  :after (org))
(use-package ol-grep
  :after (org))

;; built-in org-mode
(use-package ol-eshell
  :after (org))
(use-package ol-git-link
  :defer 2
  :after (org))
(use-package ol-gnus
  :defer 2
  :after (org))
(use-package ol-irc
  :defer 2
  :after (org))
(use-package ol-info
  :defer 2
  :after (org))
(use-package ol-man
  :defer 2
  :after (org))
;; (use-package ol-notmuch
;;   :defer 2
;;   :after (org))
;; (use-package ob-dot
;;   :after org
;;   :commands (org-babel-execute:dot))
;; (use-package ob-ditaa
;;   :after org
;;   :commands (org-babel-execute:ditaa)
;;   :config
;;   (setq org-ditaa-jar-path "/home/vincent/.nix-profile/lib/ditaa.jar"))
;; (use-package ob-doc-makefile
;;   :after org
;;   :commands (org-babel-execute:makefile))

(use-package org-nix-shell
  :hook (org-mode . org-nix-shell-mode))

(use-package org-rich-yank
  :after org
  :bind (:map org-mode-map
              ("C-M-y" . org-rich-yank)))

;; (use-package org
;;   ;; :ensure org-plus-contrib ;; load from the package instead of internal
;;   :mode (("\\.org$" . org-mode)
;;          ("\\.org.draft$" . org-mode))
;;   :commands (org-agenda org-capture)
;;   :bind (("C-c o l" . org-store-link)
;;          ("C-c o r r" . org-refile)
;;          ("C-c o a a" . org-agenda)
;;          ("C-c o a r" . my/reload-org-agenda-files)
;;          ("C-c o s" . org-sort)
;;          ("<f12>" . org-agenda)
;;          ("C-c o c" . org-capture)
;;          ;; Skeletons
;;          ("C-c o i p" . vde/org-project)
;;          ("C-c o i n" . vde/org-www-post))
;;   :config
;;   (define-skeleton vde/org-project
;;     "new org-mode project"
;;     nil
;;     > "#+TITLE: " (skeleton-read "Title: ") \n
;;     > "#+FILETAGS: " (skeleton-read "Tags: ") \n
;;     > "#+CATEGORY: " (skeleton-read "Category: ") \n
;;     > _ \n
;;     > _ \n)
;;   (define-auto-insert '("/projects/.*\\.org\\'" . "projects org files") [vde/org-project])
;;   (define-skeleton vde/org-www-post
;;     "new www post"
;;     nil
;;     > "#+title: " (skeleton-read "Title: ") \n
;;     > "#+date: " (format-time-string "<%Y-%m-%d %a>") \n
;;     > "#+filetags: " (skeleton-read "Tags: ") \n
;;     > "#+setupfile: " (skeleton-read "Template (default ../templates/2022.org): ") \n
;;     > _ \n
;;     > "* Introduction"
;;     )
;;   (define-auto-insert '("/content/.*\\.org\\'" . "blog post org files") [vde/org-www-post])
;;   (define-auto-insert '("/content/.*\\.draft\\'" . "blog post draft files") [vde/org-www-post])
;;   ;; Org Babel configurations
;;   (when (file-exists-p org-babel-library-file)
;;     (org-babel-lob-ingest org-babel-library-file))
;;   (setq org-tag-alist '(("linux") ("nixos") ("emacs") ("org")
;;                         ("openshift") ("redhat") ("tektoncd") ("kubernetes") ("knative" ) ("docker")
;;                         ("docs") ("code") ("review")
;;                         (:startgroup . nil)
;;                         ("#home" . ?h) ("#work" . ?w) ("#errand" . ?e) ("#health" . ?l)
;;                         (:endgroup . nil)
;;                         (:startgroup . nil)
;;                         ("#link" . ?i) ("#read" . ?r) ("#project" . ?p)
;;                         (:endgroup . nil))
;;         org-enforce-todo-dependencies t
;;         org-outline-path-complete-in-steps nil
;;         org-columns-default-format "%80ITEM(Task) %TODO %3PRIORITY %10Effort(Effort){:} %10CLOCKSUM"
;;         org-fontify-whole-heading-line t
;;         org-pretty-entities t
;;         org-ellipsis " ⤵"
;;         org-archive-location (concat org-completed-dir "/%s::datetree/")
;;         org-use-property-inheritance t
;;         org-priority 67
;;         org-priority-faces '((?A . "#ff2600")
;;                              (?B . "#ff5900")
;;                              (?C . "#ff9200")
;;                              (?D . "#747474"))
;;         org-global-properties (quote (("EFFORT_ALL" . "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 0:00")
;;                                       ("STYLE_ALL" . "habit")))
;;         org-blank-before-new-entry '((heading . t)
;;                                      (plain-list-item . nil))
;;         org-insert-heading-respect-content t
;;         org-yank-adjusted-subtrees t
;;         org-image-actual-width nil
;;         org-startup-with-inline-images nil
;;         org-catch-invisible-edits 'error
;;         ;; Put theses into a minor mode
;;         org-indent-indentation-per-level 1
;;         org-cycle-separator-lines 1
;;         org-adapt-indentation nil
;;         org-hide-leading-stars t
;;         org-hide-emphasis-markers nil
;;         org-link-file-path-type 'relative)
;;   (setcar (nthcdr 4 org-emphasis-regexp-components) 10)
;;   :hook (org-mode . vde/org-mode-hook))
;; 
;; (defun vde/org-mode-hook ()
;;   "Org-mode hook"
;;   (setq show-trailing-whitespace t)
;;   (when (not (eq major-mode 'org-agenda-mode))
;;     (setq fill-column 90)
;;     (auto-revert-mode)
;;     (auto-fill-mode)
;;     (org-indent-mode)
;;     (add-hook 'before-save-hook #'save-and-update-includes nil 'make-it-local)))
;; (use-package org-agenda
;;   :after org
;;   :commands (org-agenda)
;;   :bind (("C-c o a a" . org-agenda)
;;          ("<f12>" . org-agenda)
;;          ("C-c o r a" . org-agenda-refile))
;;   :config
;;   (use-package org-super-agenda
;;     :config (org-super-agenda-mode))
;;   (setq org-agenda-span 'day
;;         org-agenda-start-on-weekday 1
;;         org-agenda-include-diary t
;;         org-agenda-window-setup 'current-window
;;         org-agenda-skip-scheduled-if-done nil
;;         org-agenda-compact-blocks t
;;         org-agenda-sticky t
;;         org-super-agenda-header-separator ""
;;         org-agenda-custom-commands
;;         `(("l" "Links"
;;            tags "+#link")
;;           ("w" "Agenda"
;;            ((agenda "")
;;             (tags-todo "-goals-incubate-inbox+TODO=\"STARTED\""
;;                        ((org-agenda-overriding-header "Ongoing")))
;;             (tags-todo "-goals-incubate-inbox+TODO=\"NEXT\""
;;                        ((org-agenda-overriding-header "Next"))))
;;            ((org-super-agenda-groups
;;              '((:name "Important" :priority "A")
;;                (:name "Scheduled" :time-grid t)
;;                (:habit t))))
;;            (org-agenda-list)))))


;; (use-package org-clock
;;   :after org
;;   :commands (org-clock-in org-clock-out org-clock-goto)
;;   :config
;;   ;; Setup hooks for clock persistance
;;   (org-clock-persistence-insinuate)
;;   (setq org-clock-clocked-in-display nil
;;         ;; Show lot of clocking history so it's easy to pick items off the C-F11 list
;;         org-clock-history-length 23
;;         ;; Change tasks to STARTED when clocking in
;;         org-clock-in-switch-to-state 'vde/clock-in-to-started
;;         ;; Clock out when moving task to a done state
;;         org-clock-out-when-done t
;;         ;; Save the running clock and all clock history when exiting Emacs, load it on startup
;;         org-clock-persist t)
;;   (use-package find-lisp)
;;   (defun vde/is-project-p ()
;;     "Any task with a todo keyword subtask"
;;     (save-restriction
;;       (widen)
;;       (let ((has-subtask)
;;             (subtree-end (save-excursion (org-end-of-subtree t)))
;;             (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
;;         (save-excursion
;;           (forward-line 1)
;;           (while (and (not has-subtask)
;;                       (< (point) subtree-end)
;;                       (re-search-forward "^\*+ " subtree-end t))
;;             (when (member (org-get-todo-state) org-todo-keywords-1)
;;               (setq has-subtask t))))
;;         (and is-a-task has-subtask))))
;; 
;;   (defun vde/is-project-subtree-p ()
;;     "Any task with a todo keyword that is in a project subtree.
;; Callers of this function already widen the buffer view."
;;     (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
;;                                 (point))))
;;       (save-excursion
;;         (vde/find-project-task)
;;         (if (equal (point) task)
;;             nil
;;           t))))
;; 
;;   (defun vde/find-project-task ()
;;     "Move point to the parent (project) task if any"
;;     (save-restriction
;;       (widen)
;;       (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
;;         (while (org-up-heading-safe)
;;           (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
;;             (setq parent-task (point))))
;;         (goto-char parent-task)
;;         parent-task)))
;; 
;;   (defun vde/is-task-p ()
;;     "Any task with a todo keyword and no subtask"
;;     (save-restriction
;;       (widen)
;;       (let ((has-subtask)
;;             (subtree-end (save-excursion (org-end-of-subtree t)))
;;             (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
;;         (save-excursion
;;           (forward-line 1)
;;           (while (and (not has-subtask)
;;                       (< (point) subtree-end)
;;                       (re-search-forward "^\*+ " subtree-end t))
;;             (when (member (org-get-todo-state) org-todo-keywords-1)
;;               (setq has-subtask t))))
;;         (and is-a-task (not has-subtask)))))
;; 
;;   (defun vde/is-subproject-p ()
;;     "Any task which is a subtask of another project"
;;     (let ((is-subproject)
;;           (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
;;       (save-excursion
;;         (while (and (not is-subproject) (org-up-heading-safe))
;;           (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
;;             (setq is-subproject t))))
;;       (and is-a-task is-subproject)))
;; 
;;   (defun vde/clock-in-to-started (kw)
;;     "Switch a task from TODO to STARTED when clocking in.
;; Skips capture tasks, projects, and subprojects.
;; Switch projects and subprojects from STARTED back to TODO"
;;     (when (not (and (boundp 'org-capture-mode) org-capture-mode))
;;       (cond
;;        ((and (member (org-get-todo-state) (list "TODO" "NEXT"))
;;              (vde/is-task-p))
;;         "STARTED")
;;        ((and (member (org-get-todo-state) (list "STARTED"))
;;              (vde/is-project-p))
;;         "TODO"))))
;;   :bind (("<f11>" . org-clock-goto)))
;; (use-package org-habit
;;   :after (org)
;;   :config
;;   (setq org-habit-show-habits-only-for-today nil
;;         org-habit-graph-column 80))
;; (use-package org-src
;;   :after (org)
;;   :config
;;   (setq org-src-fontify-natively t
;;         org-src-tab-acts-natively t
;;         org-src-window-setup 'current-window
;;         org-edit-src-content-indentation 0))
;; (use-package org
;;   :defer 2
;;   :config
;;   (defun vde/tangle-all-notes ()
;;     "Produce files from my notes folder.
;; This function will attempt to tangle all org files from `org-notes-dir'. The
;; assumption is that those will generate configuration file (in `~/src/home'),
;; and thus keeping the configuration source up-to-date"
;;     (mapc (lambda (x) (org-babel-tangle-file x))
;;           (ignore-errors
;;             (append (directory-files-recursively org-notes-dir "\.org$")
;;                     (directory-files-recursively src-home-dir "\.org$"))))))
;; (use-package org-journal
;;   :commands (org-journal-new-entry org-capture)
;;   :after org
;;   :bind
;;   (("C-c n j" . org-journal-new-entry)
;;    ("C-c o j" . org-journal-new-entry))
;;   :config
;;   (defun org-journal-find-location ()
;;     "Go to the beginning of the today's journal file.
;; 
;; This can be used for an org-capture template to create an entry in the journal."
;;     ;; Open today's journal, but specify a non-nil prefix argument in order to
;;     ;; inhibit inserting the heading; org-capture will insert the heading.
;;     (org-journal-new-entry t)
;;     ;; Position point on the journal's top-level heading so that org-capture
;;     ;; will add the new entry as a child entry.
;;     (widen)
;;     (goto-char (point-min))
;;     (org-show-entry))
;;   (add-to-list 'org-capture-templates
;;                `("j" "Journal"))
;;   (add-to-list 'org-capture-templates
;;                `("jj" "Journal entry" entry (function org-journal-find-location)
;;                  "** %(format-time-string org-journal-time-format)%^{Title}\n%i%?"
;;                  :empty-lines 1))
;;   (add-to-list 'org-capture-templates
;;                `("je" "Weekly review" entry (function org-journal-find-location)
;;                  (file ,(expand-file-name "etc/orgmode/weekly.org" user-emacs-directory))
;;                  :empty-lines 1 :clock-in t :clock-resume t))
;;   :custom
;;   (org-journal-date-prefix "* ")
;;   (org-journal-file-header "#+TITLE: %Y-%m Journal\n\n")
;;   (org-journal-file-format "%Y-%m.private.org")
;;   (org-journal-file-type 'monthly)
;;   (org-journal-dir org-private-notes-dir)
;;   (org-journal-date-format "%A, %d %B %Y")
;;   (org-journal-enable-agenda-integration nil))
;; 
;;   (defun contrib/org-get-id (&optional pom create prefix)
;;     "Get the CUSTOM_ID property of the entry at point-or-marker
;; POM. If POM is nil, refer to the entry at point. If the entry
;; does not have an CUSTOM_ID, the function returns nil. However,
;; when CREATE is non nil, create a CUSTOM_ID if none is present
;; already. PREFIX will be passed through to `org-id-new'. In any
;; case, the CUSTOM_ID of the entry is returned."
;;     (org-with-point-at pom
;;       (let ((id (org-entry-get nil "CUSTOM_ID")))
;;         (cond
;;          ((and id (stringp id) (string-match "\\S-" id))
;;           id)
;;          (create
;;           (setq id (org-id-new (concat prefix "h")))
;;           (org-entry-put pom "CUSTOM_ID" id)
;;           (org-id-add-location id (buffer-file-name (buffer-base-buffer)))
;;           id)))))
;; )
;; (use-package org-crypt
;;   :after (org)
;;   :config
;;   (org-crypt-use-before-save-magic)
;;   (setq org-tags-exclude-from-inheritance '("crypt")))
;; (use-package org-attach
;;   :after org
;;   :config
;;   (setq org-link-abbrev-alist '(("att" . org-attach-expand-link))))
;; (use-package ox-publish
;;   :after org
;;   :commands (org-publish org-publish-all org-publish-project org-publish-current-project org-publish-current-file)
;;   :config
;;   (setq org-html-coding-system 'utf-8-unix))
;; (use-package diary-lib
;;   :after (org)
;;   :config
;;   (setq diary-entry-marker "diary")
;;   (setq diary-show-holidays-flag t)
;;   (setq diary-header-line-flag nil)
;;   (setq diary-mail-days 3)
;;   (setq diary-number-of-entries 3)
;;   (setq diary-comment-start ";")
;;   (setq diary-comment-end "")
;;   (setq diary-date-forms
;;         '((day "/" month "[^/0-9]")
;;           (day "/" month "/" year "[^0-9]")
;;           (day " *" monthname " *" year "[^0-9]")
;;           (monthname " *" day "[^,0-9]")
;;           (monthname " *" day ", *" year "[^0-9]")
;;           (year "[-/]" month "[-/]" day "[^0-9]")
;;           (dayname "\\W"))))
;; 
;; (use-package org
;;   :defer t
;;   :config
;; 
;;   (defvar org-capture-templates (list))
;;   (setq org-protocol-default-template-key "l")
;; 
;;   ;; images
;;   (setq org-image-actual-width nil
;;         org-startup-with-inline-images nil)
;; 
;;   ;; Tasks (-> inbox)
;; 
;;   ;; Journal
;; 
;;   (add-to-list 'ispell-skip-region-alist '(":\\(PROPERTIES\\|LOGBOOK\\):" ":END:"))
;;   (add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_SRC" "#\\+END_SRC"))
;;   (add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_EXAMPLE" "#\\+END_EXAMPLE"))
;; 
;;   ;; org-links
;;   ;; from http://endlessparentheses.com/use-org-mode-links-for-absolutely-anything.html
;;   (org-link-set-parameters "tag"
;;                            :follow #'endless/follow-tag-link)
;;   (defun endless/follow-tag-link (tag)
;;     "Display a list of TODO headlines with tag TAG.
;; With prefix argument, also display headlines without a TODO keyword."
;;     (org-tags-view (null current-prefix-arg) tag))
;; 
;;   (org-link-set-parameters
;;    "org"
;;    :complete (lambda () (+org-link-read-file "org" org-directory))
;;    :follow   (lambda (link) (find-file (expand-file-name link org-directory)))
;;    :face     (lambda (link)
;;                (if (file-exists-p (expand-file-name link org-directory))
;;                    'org-link
;;                  'error)))
;;   (defun +org-link-read-file (key dir)
;;     (let ((file (read-file-name (format "%s: " (capitalize key)) dir)))
;;       (format "%s:%s"
;;               key
;;               (file-relative-name file dir))))
;;   )
;; 
;; (use-package org-tree-slide
;;   :functions (org-display-inline-images
;;               org-remove-inline-images)
;;   :bind (:map org-mode-map
;;               ("s-<f7>" . org-tree-slide-mode)
;;               :map org-tree-slide-mode-map
;;               ("<left>" . org-tree-slide-move-previous-tree)
;;               ("<right>" . org-tree-slide-move-next-tree)
;;               ("S-SPC" . org-tree-slide-move-previous-tree)
;;               ("SPC" . org-tree-slide-move-next-tree))
;;   :hook ((org-tree-slide-play . (lambda ()
;;                                   (text-scale-increase 4)
;;                                   (org-display-inline-images)
;;                                   (read-only-mode 1)))
;;          (org-tree-slide-stop . (lambda ()
;;                                   (text-scale-increase 0)
;;                                   (org-remove-inline-images)
;;                                   (read-only-mode -1))))
;;   :init (setq org-tree-slide-header t
;;               org-tree-slide-slide-in-effect nil
;;               org-tree-slide-heading-emphasis nil
;;               org-tree-slide-cursor-init t
;;               org-tree-slide-modeline-display 'outside
;;               org-tree-slide-skip-done nil
;;               org-tree-slide-skip-comments t
;;               org-tree-slide-content-margin-top 1
;;               org-tree-slide-skip-outline-level 4))

;; from https://sachachua.com/blog/2024/01/using-consult-and-org-ql-to-search-my-org-mode-agenda-files-and-sort-the-results-to-prioritize-heading-matches/
(defun my-consult-org-ql-agenda-jump ()
  "Search agenda files with preview."
  (interactive)
  (let* ((marker (consult--read
                  (consult--dynamic-collection
                   #'my-consult-org-ql-agenda-match)
                  :state (consult--jump-state)
                  :category 'consult-org-heading
                  :prompt "Heading: "
                  :sort nil
                  :lookup #'consult--lookup-candidate))
         (buffer (marker-buffer marker))
         (pos (marker-position marker)))
    ;; based on org-agenda-switch-to
    (unless buffer (user-error "Trying to switch to non-existent buffer"))
    (pop-to-buffer-same-window buffer)
    (goto-char pos)
    (when (derived-mode-p 'org-mode)
      (org-fold-show-context 'agenda)
      (run-hooks 'org-agenda-after-show-hook))))

(defun my-consult-org-ql-agenda-format (o)
  (propertize
   (org-ql-view--format-element o)
   'consult--candidate (org-element-property :org-hd-marker o)))

(defun my-consult-org-ql-agenda-match (string)
  "Return candidates that match STRING.
Sort heading matches first, followed by other matches.
Within those groups, sort by date and priority."
  (let* ((query (org-ql--query-string-to-sexp string))
         (sort '(date reverse priority))
         (heading-query (-tree-map (lambda (x) (if (eq x 'rifle) 'heading x)) query))
         (matched-heading
          (mapcar #'my-consult-org-ql-agenda-format
                  (org-ql-select 'org-agenda-files heading-query
                    :action 'element-with-markers
                    :sort sort)))
         (all-matches
          (mapcar #'my-consult-org-ql-agenda-format
                  (org-ql-select 'org-agenda-files query
                    :action 'element-with-markers
                    :sort sort))))
    (append
     matched-heading
     (seq-difference all-matches matched-heading))))

(use-package org-ql
  :after org
  :bind ("M-s a" . my-consult-org-ql-agenda-jump))

(use-package org-ql-view
  :after org-ql)


;; TODO NEXT STARTED IN-REVIEW DONE CANCELED WAITING SOMEDAY IDEA
(defun my-org-todo-set-keyword-faces ()
  (setq org-todo-keyword-faces
        `(("TODO" . (:foreground ,(modus-themes-get-color-value 'red-faint) :weight bold))
          ("NEXT" . (:foreground ,(modus-themes-get-color-value 'yellow-warmer) :weight bold))
          ("STARTED" . (:foreground ,(modus-themes-get-color-value 'yellow-intense) :weight bold))
          ("IN-REVIEW" . (:foreground ,(modus-themes-get-color-value 'blue-faint) :weight bold))
          ("DONE" . (:foreground ,(modus-themes-get-color-value 'green-warmer) :weight bold))
          ("CANCELED" . (:foreground ,(modus-themes-get-color-value 'comment) :weight bold))
          ("WAITING" . (:foreground ,(modus-themes-get-color-value 'magenta-faint) :weight bold))
          ("SOMEDAY" . (:foreground ,(modus-themes-get-color-value 'cyan-warmer) :weight bold))
          ("IDEA" . (:foreground ,(modus-themes-get-color-value 'magenta-cooler) :weight bold))))
  (setq org-modern-todo-faces
        `(("TODO" . (:foreground ,(modus-themes-get-color-value 'fg-term-white-bright) :background ,(modus-themes-get-color-value 'red-faint) :weight bold))
          ("NEXT" . (:foreground ,(modus-themes-get-color-value 'fg-term-white-bright) :background ,(modus-themes-get-color-value 'yellow-warmer) :weight bold))
          ("STARTED" . (:foreground ,(modus-themes-get-color-value 'fg-term-white-bright) :background ,(modus-themes-get-color-value 'yellow-intense) :weight bold))
          ("IN-REVIEW" . (:foreground ,(modus-themes-get-color-value 'fg-term-white-bright) :background ,(modus-themes-get-color-value 'blue-faint) :weight bold))
          ("DONE" . (:foreground ,(modus-themes-get-color-value 'fg-term-white-bright) :background ,(modus-themes-get-color-value 'green-warmer) :weight bold))
          ("CANCELED" . (:foreground ,(modus-themes-get-color-value 'fg-term-white-bright) :background ,(modus-themes-get-color-value 'comment) :weight bold))
          ("WAITING" . (:foreground ,(modus-themes-get-color-value 'fg-term-white-bright) :background ,(modus-themes-get-color-value 'magenta-faint) :weight bold))
          ("SOMEDAY" . (:foreground ,(modus-themes-get-color-value 'fg-term-white-bright) :background ,(modus-themes-get-color-value 'cyan-warmer) :weight bold))
          ("IDEA" . (:foreground ,(modus-themes-get-color-value 'fg-term-white-bright) :background ,(modus-themes-get-color-value 'magenta-cooler) :weight bold))))
  (when (derived-mode-p 'org-mode)
    (font-lock-fontify-buffer)))
(my-org-todo-set-keyword-faces)
(with-eval-after-load 'modus-themes
  (add-hook 'modus-themes-after-load-theme-hook #'my-org-todo-set-keyword-faces))

(provide 'config-org)
;;; config-org.el ends here
