;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customizations

(defgroup portal nil
  "Portal group."
  :group 'convenience)

(defcustom portal-outputs-directory
  "~/.portals/"
  "Directory where to create output artifacts."
  :type 'string :group 'portal)

(defcustom portal-default-stdout-buffer-len
  4096
  "Default buffer length for the stdout preview."
  :group 'portal :type 'number)

(defcustom portal-default-stderr-buffer-len
  4096
  "Default buffer length for the stderr preview."
  :group 'portal :type 'number)

(defface portal-face
  '((((class color) (background dark))
     (:foreground "#fff" :bold t))
    (((class color) (background light))
     (:foreground "#000" :bold t)))
  "Portal face."
  :group 'portal)

(defface portal-exited-stdout-face
  '((t :foreground "#acac9e"))
  "Portal exited stdout face."
  :group 'portal)

(defface portal-exited-stderr-face
  '((t :foreground "#aa7070"))
  "Portal exited stderr face."
  :group 'portal)

(defface portal-exit-success-face
  '((t :foreground "#89b664"))
  "Portal exit successful face."
  :group 'portal)

(defface portal-exit-failure-face
  '((t :foreground "#ae6161"))
  "Portal exit failure face."
  :group 'portal)

(defface portal-meta-face
  '((t :foreground "#89b664"))
  "Portal meta face."
  :group 'portal)

(defface portal-stdout-face
  '((t :inherit 'default))
  "Portal stdout face."
  :group 'portal)

(defface portal-stderr-face
  '((t :foreground "#ae6161"))
  "Portal stderr face."
  :group 'portal)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interactive commands

(defun portal-insert-shell-command (command)
  "Launch an asynchronous shell of COMMAND, make a portal associated
with the current buffer and insert the portal into the current
buffer."
  (interactive "sCommand: ")
  (portal-insert-command
   (list shell-file-name shell-command-switch command)))

(defun portal-open-stdout ()
  "Open the stdout of the file at point."
  (interactive)
  (find-file (portal-file-name (portal-at-point) "stdout")))

(defun portal-open-stderr ()
  "Open the stderr of the file at point."
  (interactive)
  (find-file (portal-file-name (portal-at-point) "stderr")))

(defun portal-interrupt ()
  "Interrupt the process at point."
  (interactive)
  (let ((proc (get-process (portal-process-name (portal-at-point)))))
    (when (process-live-p proc)
      (interrupt-process proc))))

(defun portal-rerun ()
  "Re-run portal at point."
  (interactive)
  (portal-jump-to-portal)
  (let* ((portal (portal-at-point))
         (command (portal-read-json-file portal "command"))
         (env (portal-read-json-file portal "env"))
         (default-directory (portal-read-json-file portal "directory")))
    (portal-interrupt)
    (delete-region (line-beginning-position) (line-end-position))
    (portal-wipe-summary)
    (portal-insert-command (append command nil))
    (portal-refresh-soon)))

(defun portal-edit ()
  "Edit and re-run portal at point."
  (interactive)
  (portal-jump-to-portal)
  (portal-interrupt)
  (let* ((portal (portal-at-point))
         (command
          (vector
           shell-file-name
           shell-command-switch
           (read-from-minibuffer
            "Command: "
            (portal-as-shell-command (portal-read-json-file portal "command")))))
         (env (portal-read-json-file portal "env"))
         (default-directory (portal-read-json-file portal "directory")))
    (delete-region (line-beginning-position) (line-end-position))
    (portal-wipe-summary)
    (portal-insert-command (append command nil))
    (portal-refresh-soon)))

(defun portal-clone ()
  "Clone the portal at point."
  (interactive)
  (portal-jump-to-portal)
  (let* ((portal (portal-at-point))
         (command (portal-read-json-file portal "command"))
         (env (portal-read-json-file portal "env"))
         (default-directory (portal-read-json-file portal "directory")))
    (save-excursion (insert "\n"))
    (portal-insert-command (append  command nil))
    (portal-refresh-soon)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Launching processes

(defun portal-start (buffer portal stdout-path stderr-path program program-args)
  "Run PROGRAM-PATH with ARGS, connect it to portal PORTAL in buffer
BUFFER, and write the stdout to STDOUT-PATH and stderr to
STDERR-PATH."
  (let* ((stderr-pipe
          (make-pipe-process
           :name (portal-stderr-process-name portal)
           :buffer buffer
           :noquery t
           :filter 'portal-process-filter
           :sentinel 'portal-stderr-pipe-sentinel))
         (main-process
          (make-process
           :name (portal-process-name portal)
           :buffer buffer
           :command (cons program program-args)
           :noquery nil
           :connection-type 'pipe
           :sentinel 'portal-main-process-sentinel
           :filter 'portal-process-filter
           :stderr stderr-pipe)))

    (process-put stderr-pipe :portal portal)
    (process-put stderr-pipe :output-path stderr-path)
    (process-put stderr-pipe :buffer "")
    (process-put stderr-pipe :buffer-len portal-default-stderr-buffer-len)

    (process-put main-process :portal portal)
    (process-put main-process :output-path stdout-path)
    (process-put main-process :buffer "")
    (process-put main-process :buffer-len portal-default-stdout-buffer-len)

    ;; Connect the two processes.
    (process-put main-process :stderr-process stderr-pipe)

    (portal-write-json-file portal "command" (apply #'vector (cons program program-args)))
    (portal-write-json-file portal "env" (apply #'vector process-environment))
    (portal-write-json-file portal "directory" default-directory)
    (portal-write-json-file portal "status" (format "%S" (process-status main-process)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Process filtering

(defun portal-process-filter (process output)
  (let ((filepath (process-get process :output-path)))
    (when debug-on-error
      (message "portal-process-filter: Writing to %s" filepath))
    (portal-accumulate-buffer process output)
    (with-temp-buffer
      (insert output)
      (write-region (point-min) (point-max) filepath :append :no-messages))))

(defun portal-accumulate-buffer (process output)
  "Accumulate some OUTPUT into PROCESS's preview buffer."
  (process-put
   process
   :buffer (portal-shrink-preview
            (process-get process :buffer-len)
            (concat (process-get process :buffer) output))))

(defun portal-shrink-preview (len string)
  "Shrink a preview buffer STRING to the right length."
  (if (> (length string) len)
      (substring string (- len))
    string))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sentinels

(defun portal-main-process-sentinel (process event)
  "Handles the main process's status updates."
  (when debug-on-error
    (message "main-process-sentinel: %S: %S" process event))
  (portal-write-json-file
   (process-get process :portal)
   "status" (format "%S" (process-exit-status process))))

(defun portal-stderr-pipe-sentinel (process event)
  "Handles the stderr pipe's status updates."
  (when debug-on-error
    (message "stderr-pipe-sentinel: %S: %S" process event)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File/directory operations

(defun portal-ensure-directory (portal)
  "Create the stdout/stderr files for PORTAL in an appropriate
location."
  (let ((directory (concat (file-name-as-directory portal-outputs-directory) portal)))
    (make-directory directory :including-parents)
    directory))

(defun portal-directory-exists-p (portal)
  "Check PORTAL has a directory that exists."
  (let ((directory (concat (file-name-as-directory portal-outputs-directory) portal)))
    (file-exists-p directory)))

(defun portal-file-exists-p (portal name)
  "Check PORTAL has a file NAME that exists."
  (let ((directory (concat (file-name-as-directory portal-outputs-directory) portal)))
    (file-exists-p (concat (file-name-as-directory directory) name))))

(defun portal-persist-file (portal name content)
  "Persist CONTENT to disk with filename NAME."
  (with-temp-buffer
    (insert content)
    (write-region
     (point-min) (point-max)
     (portal-file-name portal name)
     nil ; no-append
     :no-messages))
  content)

(defun portal-write-json-file (portal name expr)
  "Print EXPR to disk with filename NAME."
  (with-temp-buffer
    (insert (json-serialize expr))
    (write-region
     (point-min) (point-max)
     (portal-file-name portal name)
     nil ; no-append
     :no-messages))
  expr)

(defun portal-read-json-file (portal name)
  "Read JSON content from file NAME for the given PORTAL."
  (with-temp-buffer
    (insert-file-contents (portal-file-name portal name))
    (json-parse-string (buffer-string))))

(defun portal-read-file (portal name)
  "Read content from file NAME for the given PORTAL."
  (with-temp-buffer
    (let ((file (portal-file-name portal name)))
      (when (file-exists-p file)
        (insert-file-contents file)))
    (buffer-string)))

(defun portal-tail-file (portal n name)
  "Tail last N lines of file NAME for the given PORTAL."
  (with-temp-buffer
    (let ((file (portal-file-name portal name)))
      (if (file-exists-p file)
          (portal-tail-n-lines n file)
        ""))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Nano-IDs

(defun portal-generate-nanoid ()
  "Generate a Nano ID of the form `portal_NGMyMDVkZjZiYTVlZTVhM' using SHA-1."
  (let* ((random-string (format "%s%s%S" (emacs-pid) (current-time-string) (random)))
         (sha1-hash (secure-hash 'sha1 random-string))
         (base64-encoded (base64-encode-string sha1-hash))
         (nanoid (string-trim-right (substring base64-encoded 0 21))))
    (concat "portal_" nanoid)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A small minor mode that just sets up a timer that runs a thing in a
;; given buffer every N seconds

(defvar-local portal-alpha-timer
    nil)

(define-minor-mode portal-alpha-minor-mode
  "TODO"
  :init-value nil
  :lighter "@"
  (when portal-alpha-timer (cancel-timer portal-alpha-timer))
  (when portal-alpha-minor-mode
    (setq portal-alpha-timer
          (run-with-timer 1 2 'portal-beta-refresh (current-buffer)))))

(defun portal-refresh-soon ()
  "Trigger a refresh within the blink of an eye, but no sooner, or
later."
  (run-with-timer 0.100 nil 'portal-beta-refresh (current-buffer)))

(defun portal-beta-refresh (buffer)
  "Refresh portal displays."
  (when (buffer-live-p buffer)
    (let ((window (get-buffer-window buffer)))
      (when window
        (with-current-buffer buffer
          (let ((point (point)))
            (save-excursion
              (goto-char (point-min))
              (while (and (re-search-forward portal-regexp nil t nil)
                          (<= (point) (window-end window)))
                (when (<= (window-start window) (point) (window-end window))
                  (let* ((portal (match-string 0))
                         (process (get-process (portal-process-name portal)))
                         (summary (if (portal-directory-exists-p portal)
                                      (portal-summary portal process)
                                    "# Invalid portal."))
                         (match-end (match-end 0))
                         (old-summary (get-text-property (line-beginning-position) 'portal-summary)))
                    (unless (and old-summary (string= summary old-summary))
                      (put-text-property (line-beginning-position) (point)
                                         'portal-summary
                                         summary)
                      (put-text-property (line-beginning-position) (point)
                                         'portal
                                         portal)
                      (portal-wipe-summary)
                      (insert "\n" summary))))))
            (goto-char point)))))))

(defun portal-wipe-summary ()
  "Wipe the '# summary' lines that follow the portal."
  (save-excursion
    (when (looking-at "\n#")
      (forward-line 1)
      (let ((point (point)))
        (or (search-forward-regexp "^[^#]" nil t 1)
            (goto-char (point-max)))
        (delete-matching-lines "^#" point (point))))))

(defun portal-summary (portal process)
  "Generate a summary of the portal."
  (let* ((command (portal-read-json-file portal "command"))
         (directory (portal-read-json-file portal "directory"))
         (status (portal-read-json-file portal "status"))
         (stdout (if process
                     (portal-last-n-lines
                      5
                      (process-get process :buffer))
                   (portal-tail-file portal 5 "stdout")))
         (stderr (if process
                     (portal-last-n-lines
                      5
                      (process-get (process-get process :stderr-process) :buffer))
                   (portal-tail-file portal 5 "stderr"))))
    (with-temp-buffer
      (insert (propertize
               (concat "# (" (if (string= status "run") "🌀" status) ") " (portal-as-shell-command command))
               'face
               (if (string= status "run")
                   'portal-meta-face
                 (if (string= status "0")
                     'portal-exit-success-face
                   'portal-exit-failure-face))))
      ;; Only show if it's different to the current directory,
      ;; otherwise it's noise.
      (unless (string= default-directory directory) (insert "\n# " directory))
      (unless (= 0 (length (string-trim stdout)))
        (insert "\n"
                (propertize (portal-clean-output stdout)
                            'face (if (string= status "run")
                                      'portal-stdout-face
                                    'portal-exited-stdout-face))))
      (unless (= 0 (length (string-trim stderr)))
        (insert "\n"
                (propertize (portal-clean-output stderr)
                            'face
                            (if (string= status "run")
                                'portal-stderr-face
                              'portal-exited-stderr-face))))
      (propertize (buffer-string)
                  'portal portal))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; String generation

(defun portal-as-shell-command (command)
  "If the vector COMMAND is a shell run, strip the prefix, else return the whole thing joined."
  (if (and (= 3 (length command))
           (string= (elt command 0) shell-file-name)
           (string= (elt command 1) shell-command-switch))
      (elt command 2)
    (mapconcat 'shell-quote-argument command " ")))

(defun portal-clean-output (output)
  "Clean output for previewing, prefixed with #."
  (portal-limit-lines-to-80-columns
   (concat "# " (replace-regexp-in-string
                 "\n" "\n# "
                 (portal-no-empty-lines output)))))

(defun portal-limit-lines-to-80-columns (string)
  "Limit all lines in STRING to 80 columns."
  (with-temp-buffer
    (insert string)
    (goto-char (point-min))
    (while (not (eobp))
      (move-to-column 80 t)
      (delete-region (point) (line-end-position))
      (forward-line))
    (buffer-string)))

(defun portal-process-name (portal)
  (concat portal "-main-process"))

(defun portal-stderr-process-name (portal)
  (concat portal "-stderr-pipe"))

(defun portal-file-name (portal name)
  (concat (file-name-as-directory (portal-ensure-directory portal)) name))

(defun portal-no-empty-lines (string)
  "Drop empty lines from a string."
  (replace-regexp-in-string "\n$" "" string))

(defun portal-last-n-lines (n string)
  "Take last N lines from STRING."
  (mapconcat #'identity (reverse (seq-take (reverse (split-string string "[\r\n]+" t)) n)) "\n"))

(defun portal-tail-n-lines (n file-path)
  "Tail the last N lines from FILE-PATH using tail, if possible. If
not possible (due to lack of such tool), return nil."
  (let ((this-buffer (current-buffer)))
    (with-temp-buffer
      (let ((out-buffer (current-buffer)))
        (with-current-buffer this-buffer
          (cl-case (call-process "tail" nil out-buffer nil "-n" (format "%d" n)
                                 (expand-file-name file-path))
            (0 (with-current-buffer out-buffer (buffer-string)))
            (t "")))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Finding portals and gathering information for them

(defconst portal-regexp "\\<portal_[A-Za-z0-9]\\{21\\}\\>"
  "Match on a portal's unique ID.")

(defun portal-at-point ()
  "Return the portal at point."
  (or (save-excursion
        (goto-char (line-beginning-position))
        (when (looking-at portal-regexp)
          (buffer-substring (match-beginning 0) (match-end 0))))
      (get-text-property (point) 'portal)
      (error "Not at a portal.")))

(defun portal-jump-to-portal ()
  "If there's a portal at point or a summary of a portal at point,
jump to the portal at the beginning of the line upwards within
the same paragraph."
  (let ((portal (portal-at-point)))
    (goto-char
     (save-excursion
       (goto-char (line-end-position))
       (re-search-backward
        (concat "^" (regexp-quote portal))
        (save-excursion (forward-paragraph -1))
        nil
        1)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Notes

;; Use this on a portals buffer to stop it constantly being saved:
;
;; (setq buffer-save-without-query t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Major mode

(defvar-keymap portal-mode-map
  "M-!" 'portal-shell-command
  "C-c C-c" 'portal-interrupt
  "RET" 'portal-jump-to-thing-at-point
  )

(define-derived-mode portal-mode
  fundamental-mode "Portals"
  "Major mode for portals."
  (portal-alpha-minor-mode))

(defun portal-insert-command (command)
  "Launch an asynchronous proc of COMMAND, make a portal associated
with the current buffer and insert the portal into the current
buffer."
  (let* ((portal (portal-generate-nanoid)))
    (portal-start
     (current-buffer)
     portal
     (portal-file-name portal "stdout")
     (portal-file-name portal "stderr")
     (car command)
     (cdr command))
    (insert portal)))

(defun portal-shell-command (command)
  "Run a shell command and insert it at point."
  (interactive "sCommand: ")
  (portal-insert-command
   (list shell-file-name shell-command-switch command)))

(defun portal-jump-to-thing-at-point ()
  "Jump to the thing at point, i.e. an stdout/stderr output jumps to
the file."
  (interactive)
  (let ((face (get-text-property (point) 'face)))
    (cond
     ((eq face 'portal-stderr-face)
      (portal-open-stderr))
     ((eq face 'portal-exited-stderr-face)
      (portal-open-stderr))
     ((eq face 'portal-stdout-face)
      (portal-open-stdout))
     ((eq face 'portal-exited-stdout-face)
      (portal-open-stdout))
     (t (call-interactively 'newline)))))
