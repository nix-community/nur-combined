;; curl -O https://raw.githubusercontent.com/larkery/emacs/master/site-lisp/notmuch-agenda.el
;; integrate notmuch messages with org-mode agenda, by:
;; - showing agenda in message body where there's an invitation
;; - adding buttons to respond to messages

(eval-when-compile (require 'org))

(defun notmuch-agenda-datetime-as-iso (datetime)
  "Convert a date retrieved via `icalendar--get-event-property' to ISO format."
  (if datetime
    (format "%04d-%02d-%02d"
      (nth 5 datetime)                  ; Year
      (nth 4 datetime)                  ; Month
      (nth 3 datetime))))

(defun notmuch-agenda-event-time (event zone-map property)
  "Given an EVENT and a ZONE-MAP, turn the icalendar timestamp
  for PROPERTY into an emacs internal time representation"
  (let* ((timestamp (icalendar--get-event-property event property))
         (zone (icalendar--find-time-zone (icalendar--get-event-property-attributes event property)
                                          zone-map)))
    (icalendar--decode-isodatetime timestamp nil zone)))

(defun notmuch-agenda-relative-date (reference timestamp)
  (let* ((encoded-reference (apply 'encode-time reference))
         (encoded-timestamp (apply 'encode-time timestamp))

         (reference-day (nth 3 reference))
         (timestamp-day (nth 3 timestamp))

         (days (/ (float-time (time-subtract encoded-timestamp encoded-reference))
                  86400))
         (past (< days 0))
         (abs-days (abs days))
         (rem-days (% (ceiling abs-days) 7))

         (day-part
          (cond
           ((and (< abs-days 2)
                 (= reference-day timestamp-day))
            "today")
           ((and (< abs-days 2) (= (abs (- reference-day timestamp-day)) 1 ))
            (if past "yesterday" "tomorrow"))
           ((< abs-days 8) (format "%d days%s"
                                   (ceiling abs-days)
                                   (if past " ago" "")))
           (t (format "%d week%s%s%s"
                      (floor (/ abs-days 7))
                      (if (= 1 (floor (/ abs-days 7))) "" "s")
                      (if (zerop rem-days) ""
                        (format " %d days" rem-days))
                      (if past " ago" "")
                      ))
           )))

    day-part))

(defun notmuch-agenda-friendly-date (dtstart dtend rrule rdate duration)
  (let* ((now (decode-time (current-time)))
         (start-time (format-time-string "%a, %d %b %H:%M" (apply 'encode-time dtstart)))
         (rel-date (notmuch-agenda-relative-date now dtstart)))
    (concat start-time " (" rel-date ")")))

(defun notmuch-agenda-org-repeater (rrule)
  (or (and rrule
           (let* ((parts (mapcar
                          (lambda (p)
                            (let ((parts (split-string p "=")))
                              (cons (intern (car parts))
                                    (cadr parts))))
                          (split-string
                           rrule
                           ";" t "\\s-"))))

             (let ((freq (alist-get 'FREQ parts))
                   (interval (string-to-number (alist-get 'INTERVAL parts "1"))))
               (and freq interval
                    (cond
                     ((string= freq "DAILY")
                      (format " +%dd" interval))

                     ((string= freq "WEEKLY")
                      (format " +%dw" interval))

                     ((string= freq "MONTHLY")
                      (format " +%dm" interval))

                     ((string= freq "YEARLY")
                      (format " +%dy" interval)))))))
      ""))

(defun notmuch-agenda-org-date (dtstart-dec dtend-dec rrule rdate duration)
  (let* ((start-d (notmuch-agenda-datetime-as-iso dtstart-dec))
         (start-t (icalendar--datetime-to-colontime dtstart-dec))

         end-d end-t

         (repeater (notmuch-agenda-org-repeater rrule)))

    (setq end-d (if dtend-dec
                    (notmuch-agenda-datetime-as-iso dtend-dec)
                  start-d))

    (setq end-t (if dtend-dec
                    (icalendar--datetime-to-colontime dtend-dec)
                  start-t))

    (if (equal start-d end-d)
        (format "<%s %s-%s%s>" start-d start-t end-t repeater)
      (format "<%s %s>--<%s %s>" start-d start-t end-d end-t)))
  )

(defun notmuch-agenda-insert-agenda (event zone-map)
  (require 'org)
  (let* ((dtstart (notmuch-agenda-event-time event zone-map 'DTSTART))
         (wins (current-window-configuration))
         (org-agenda-sticky nil)
         (inhibit-redisplay t)
         (year (nth 5 dtstart))
         (month (nth 4 dtstart))
         (day (nth 3 dtstart))

         (org-agenda-custom-commands '(("q" "Mail agenda" ((agenda ""))))))
    (org-eval-in-environment
        (org-make-parameter-alist
         `(org-agenda-span 'day
                           org-agenda-start-day ,(format "%04d-%02d-%02d" year month day)
                           org-agenda-use-time-grid nil
                           org-agenda-remove-tags t
                           org-agenda-window-setup 'nope))

      (progn
        (save-excursion
          (org-agenda nil "q")
          (org-agenda-redo)
          (setq org-agenda-mail-buffer (current-buffer)))
        (set-window-configuration wins)
        (let ((p (point))
              pa)
          ;; copy text
          (insert-buffer-substring org-agenda-mail-buffer)

          ;; copy markers
          (save-restriction
            (narrow-to-region p (point))
            (let ((org-marker-regions
                   (with-current-buffer
                       org-agenda-mail-buffer
                     (setq pa (point-min))
                     (gnus-find-text-property-region (point-min) (point-max) 'org-marker))))
              (cl-loop for marker in org-marker-regions
                    do
                    (add-text-properties
                     (+ p (- (car marker) pa)) (+ p (- (cadr marker) pa))
                     `(org-marker
                       ,(copy-marker (get-text-property (car marker) 'org-marker org-agenda-mail-buffer))))

                    (set-marker (car marker) nil)
                    (set-marker (cadr marker) nil))))

          ;; copy faces via font-lock-face
          (save-restriction
            (narrow-to-region p (point))
            (let ((face-regions (gnus-find-text-property-region (point-min) (point-max) 'face)))
              (cl-loop for range in face-regions
                    do
                    (let ((face (get-text-property (car range) 'face)))
                      (add-text-properties
                       (car range) (cadr range)
                       `(font-lock-face ,face)))


                    (set-marker (car range) nil)
                    (set-marker (cadr range) nil))))

          (kill-buffer org-agenda-mail-buffer)
          (put-text-property p (point) 'keymap
                             org-agenda-keymap)))
      )))

(defvar notmuch-agenda-capture-targets
  `(( ,(rx "david.gubiert@atos.net")
      file "~/Documents/roam/agenda-work.org")
    ( ""
      file "~/Documents/roam/agenda.org")))

(defvar notmuch-agenda-capture-template
  ;; TODO insert also link to email
  "* %:event-summary
:PROPERTIES:
:LOCATION: %:event-location
:SEQUENCE: %:event-sequence
:ORGANIZER: [[%:event-organizer]]
:ID: %:event-uid
:END:
%:event-timestamp
%:event-comment
%:event-description
%a
%?")

(defvar notmuch-agenda-capturing-event nil)
(defvar notmuch-agenda-capturing-subject-line nil)
(defvar notmuch-agenda-capturing-message-id nil)

(defun notmuch-agenda-store-link ()
  (when notmuch-agenda-capturing-event
    (let ((event notmuch-agenda-capturing-event))
      (let ((zone-map (icalendar--convert-all-timezones (list event)))
            (props (mapcan
                    (lambda (prop)
                      (let* ((val (icalendar--get-event-property event prop))
                             (val (and val (icalendar--convert-string-for-import val))))
                        (list
                         (intern (concat ":event-" (downcase (symbol-name prop))))
                         (or val ""))))

                    (list 'LOCATION 'SEQUENCE 'UID 'SUMMARY 'COMMENT 'ORGANIZER 'DESCRIPTION))))
        (apply 'org-store-link-props
               :type "event"
               :link (format "notmuch:%s" notmuch-agenda-capturing-message-id)
               :description (format "✉ %s" notmuch-agenda-capturing-subject-line)
               :event-timestamp (notmuch-agenda-org-date
                                 (notmuch-agenda-event-time event zone-map 'DTSTART)
                                 (notmuch-agenda-event-time event zone-map 'DTEND)
                                 (icalendar--get-event-property event 'RRULE)
                                 (icalendar--get-event-property event 'RDATE)
                                 (icalendar--get-event-property event 'DURATION))
               props)))
    t))

(defun notmuch-agenda-org-capture-or-update (event)
  (require 'org-id)
  (require 'org-capture)

  (let ((existing-event (org-id-find (icalendar--get-event-property event 'UID) t)))
    (if existing-event
        (let ((use-dialog-box nil)
              (existing-sequence
               (org-entry-get existing-event "SEQUENCE")))
          (with-current-buffer
              (pop-to-buffer (marker-buffer existing-event))
            (goto-char existing-event)
            (outline-hide-sublevels 1)
            (outline-show-entry)
            (org-reveal)
            (if (>= (string-to-number existing-sequence)
                    (string-to-number (icalendar--get-event-property event 'SEQUENCE)))
                (message "Event is already in calendar")
              (when (y-or-n-p "Update event?")
                (org-entry-put nil "ID" nil)
                (org-id-update-id-locations (list buffer-file-name))
                (org-archive-subtree)
                (notmuch-agenda-org-capture-or-update event))))

          (set-marker existing-event nil nil))

      (let* ((notmuch-agenda-capturing-subject-line
              (notmuch-show-get-subject))

             (notmuch-agenda-capturing-message-id
              (notmuch-show-get-message-id))

             (notmuch-agenda-capturing-event event)

             (org-link-parameters
              '(("nope" :store notmuch-agenda-store-link)))

             (org-overriding-default-time
              (apply 'encode-time
                     (notmuch-agenda-event-time event
                                                (icalendar--convert-all-timezones (list event))
                                                'DTSTART)))

             (org-capture-templates
              `(("e" "Capture an event from email invitation"
                 entry
                 ,notmuch-agenda-capture-target
                 ,notmuch-agenda-capture-template))))
        (org-capture t "e")))))

(defun notmuch-agenda-do-capture (event)
  (let ((calendar-event (plist-get (overlay-properties event) 'calendar-event))
        (notmuch-agenda-capture-target
         (let ((addr (notmuch-show-get-to)))
           (cl-loop
            for tgt in notmuch-agenda-capture-targets
            when (string-match-p (car tgt) addr)
            return (cdr tgt)
            )))
        )
    (notmuch-agenda-org-capture-or-update calendar-event)))

(defun notmuch-agenda-insert-summary (event zone-map)
  (let* ((summary (icalendar--get-event-property event 'SUMMARY))
         (comment (icalendar--get-event-property event 'COMMENT))
         (location (icalendar--get-event-property event 'LOCATION))
         (organizer (icalendar--get-event-property event 'ORGANIZER))
         (attendees (icalendar--get-event-properties event 'ATTENDEE))
         (summary (when summary (icalendar--convert-string-for-import summary)))
         (comment (when comment (icalendar--convert-string-for-import comment)))

         (dtstart (notmuch-agenda-event-time event zone-map 'DTSTART))
         (dtend (notmuch-agenda-event-time event zone-map 'DTEND))
         (rrule (icalendar--get-event-property event 'RRULE))
         (rdate (icalendar--get-event-property event 'RDATE))
         (duration (icalendar--get-event-property event 'DURATION))
         (description (icalendar--get-event-property event 'DESCRIPTION))

         (friendly-start (notmuch-agenda-friendly-date dtstart dtend rrule rdate duration)))

    (when summary (insert (propertize summary 'face '(:underline t :height 1.5)) "\n"))

    (when (or rrule rdate) (insert (format "RRULE: %s %s\n" rrule rdate)))

    (when friendly-start
      (insert (propertize "Start: " 'face 'bold))
      (insert friendly-start "\n"))

    (when comment (insert (propertize "Comment: " 'face 'bold)
                          comment"\n"))

    (when location (insert (propertize "Location: " 'face 'bold)
                           location"\n"))
    (when organizer (insert (propertize "Organizer: " 'face 'bold)
                            (replace-regexp-in-string
                             "^mailto: *" ""
                             organizer)"\n"))
    (when attendees (insert (propertize "Attending: " 'face 'bold))
          (while attendees
            (insert (replace-regexp-in-string
                     "^mailto: *" ""
                     (car attendees)))
            (when (cdr attendees) (insert ", "))
            (setq attendees (cdr attendees)))
          (insert "\n"))

    ;; (when description
    ;;   (insert (read (format "\"%s\"" description))))

    (insert "\n")
    ))

(defun notmuch-agenda-insert-part (msg part content-type nth depth button)
  (let (icalendar-element)
    (with-temp-buffer
      ;; Get the icalendar text and stick it in a temp buffer
      (insert (notmuch-get-bodypart-text msg part notmuch-show-process-crypto))
      ;; Transform CRLF into LF
      (goto-char (point-min))
      (while (re-search-forward "\r\n" nil t) (replace-match "\n" nil nil))
      ;; Unfold the icalendar text so it can be parsed
      (set-buffer (icalendar--get-unfolded-buffer (current-buffer)))
      ;; Go to the first VCALENDAR object in the result
      (goto-char (point-min))
      (when (re-search-forward "^BEGIN:VCALENDAR\\s-*$")
        (beginning-of-line)
        (setq icalendar-element (icalendar--read-element nil nil)))
      ;; Dispose of the junk buffer produced by icalendar--get-unfolded-buffer
      (kill-buffer (current-buffer)))

    (when icalendar-element
      (let* ((events (icalendar--all-events icalendar-element))
             (zone-map (icalendar--convert-all-timezones events)))
        (insert "#+BEGIN_EXAMPLE\n")
        (dolist (event events)
          ;; insert event description string
          (notmuch-agenda-insert-summary event zone-map)
          (notmuch-agenda-insert-agenda event zone-map)
          (insert-button "[ Update agenda ]"
                         :type 'notmuch-show-part-button-type
                         'action 'notmuch-agenda-do-capture
                         'calendar-event event))
        (insert "\n#+END_EXAMPLE\n")
        t))))

(defun notmuch-agenda-reply-advice (o &rest args)
  ;; look for any text/calendar parts
  (require 'cl-lib)
  (let* ((responded (cl-intersection (notmuch-show-get-tags)
                                     '("accepted" "declined" "tentative")
                                     :test 'string=
                                     ))

         requires-response

         response

         (query (car args))
         (original (unless responded
                     (notmuch-call-notmuch-sexp
                      "reply" "--format=sexp" "--format-version=4" query)))
         (body (unless responded
                 (plist-get (plist-get original :original)
                            :body))))
    (while body
      (let ((head (car body)))
        (setq body (cdr body))
        (let ((content-type (plist-get head :content-type)))
          (cond
           ((or (string= content-type "multipart/alternative")
                (string= content-type "multipart/mixed"))
            (setq body (append body (plist-get head :content))))
           ((and (string= content-type "text/calendar")
                 (string-match-p "^METHOD:REQUEST$" (plist-get head :content)))
            (setq requires-response (plist-get head :content)
                  body nil))))))

    (when requires-response
      (setq response (completing-read "Event invitation: "
                                      '("Accepted"
                                        "Declined"
                                        "Tentative"
                                        "Ignore")
                                      nil t)))

    (when (and response (not (string= "Ignore" response)))
      (notmuch-show-tag-message (concat "+" (downcase response))))

    (apply o args)

    (when (and requires-response
               response
               (not (string= response "Ignore")))
      (require 'ox-icalendar)
      (require 'imip)

      (make-variable-buffer-local 'message-syntax-checks)
      (push '(illegible-text . disabled) message-syntax-checks)

      (save-excursion
        (goto-char (point-max))
        (save-excursion
          (mml-insert-part "text/calendar; method=REPLY")
          (insert
           (replace-regexp-in-string
            "\n" "\r\n"
            (org-icalendar-fold-string
             (with-temp-buffer
               (insert requires-response)
               (goto-char (point-min))
               (with-current-buffer
                   (icalendar--get-unfolded-buffer (current-buffer))
                 (goto-char (point-min))
                 (setq requires-response (icalendar--read-element nil nil))
                 (kill-buffer))
               (erase-buffer)

               (imip-write-element
                (imip-respond (car requires-response)
                              '("david.guibert@atos.net" "david.guibert@gmail.com")
                              (upcase response)))

               (buffer-string)))))))
      )))

(advice-add 'notmuch-mua-reply :around 'notmuch-agenda-reply-advice)

(fset 'notmuch-show-insert-part-text/calendar #'notmuch-agenda-insert-part)


(provide 'notmuch-agenda)
