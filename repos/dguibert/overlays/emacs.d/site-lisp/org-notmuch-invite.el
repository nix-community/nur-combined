;; curl -O https://raw.githubusercontent.com/larkery/emacs/master/site-lisp/org-notmuch-invite.el
(require 'org)
(require 'notmuch)
(require 'icalendar)
(require 'imip)

(defun completing-read-multiple-menu (prompt collection)
  (save-window-excursion
    (let (result results
                 (results-buffer (get-buffer-create (format "*%s*" prompt))))
      (with-selected-window
          (display-buffer-at-bottom results-buffer nil)
        (minimize-window))
      (with-current-buffer results-buffer (erase-buffer))
      (while (and (setq result (ivy-read prompt collection
                                         :def (when results "")))
                  result
                  (not (equal "" result)))

        (when (not (memql result results))
          (push result results))
        (with-current-buffer results-buffer
          (erase-buffer)
          (dolist (r results)
            (insert r)
            ;(insert "\n"))))
      results)))

(defun org-send-invitation (organizer attendees)
  (interactive
   (list (or (cdr (assoc "ORGANIZER" (org-entry-properties nil "ORGANIZER")))
             (completing-read "Organizer: " notmuch-identities nil nil))
         (or (org-entry-get-multivalued-property (point) "ATTENDING")
             (completing-read-multiple-menu "Attending: " (notmuch-address-options "cse")))))

  (org-id-get-create)

  (save-mark-and-excursion
    (let* ((sequence
            (+ 1 (string-to-number
                  (or (cdar (org-entry-properties (point) "SEQUENCE")) "-1"))))

           (headline (nth 4 (org-heading-components)))
           (ics-file
            (save-restriction
              (org-narrow-to-subtree)
              (org-icalendar-export-to-ics nil nil nil)))

           (event
            (car
             (with-temp-buffer
               (insert-file-contents ics-file nil)
               (delete-file ics-file)
               (let* ((unfolded (icalendar--get-unfolded-buffer (current-buffer)))
                      (event (with-current-buffer unfolded
                               (goto-char (point-min))
                               (icalendar--read-element nil nil))))
                 (kill-buffer unfolded)
                 event)))))

      (message "%s" event)

      (setf
       (alist-get 'METHOD (nth 2 event))
       '(nil "REQUEST"))

      (let ((vevent (nth 0 (nth 3 event))))
        (setf
         (alist-get 'TRANSP (nth 2 vevent))
         '(nil "OPAQUE"))

        (setf
         (alist-get 'CLASS (nth 2 vevent))
         '(nil "PUBLIC"))

        (setf
         (alist-get 'STATUS (nth 2 vevent))
         '(nil "CONFIRMED"))

        (setf
         (alist-get 'SEQUENCE (nth 2 vevent))
         `(nil ,(number-to-string sequence)))


        (dolist (addr attendees)
          (let ((addr (mail-extract-address-components addr)))
            (push
             `(ATTENDEE
               (ROLE "REQ-PARTICIPANT"
                     PARTSTAT "NEEDS-ACTION"
                     RSVP "TRUE"
                     ;; ,@(when (car addr)
                     ;;     (list 'CN (car addr)))
                     )
               ,(format "mailto:%s" (cadr addr)))
             (nth 2 vevent))))

        (setf
         (alist-get 'ORGANIZER (nth 2 vevent))
         (let ((addr (mail-extract-address-components organizer)))
           `(;; (RSVP "FALSE" PARTSTAT "ACCEPTED"
             ;;       ,@(when (car addr)
             ;;           (list 'CN (car addr))))
             nil
             ,(format "mailto:%s" (cadr addr))))))

      (org-set-property "SEQUENCE" (number-to-string sequence))
      (org-set-property "ORGANIZER" organizer)
      (apply #'org-entry-put-multivalued-property (point) "ATTENDING" attendees)

      (notmuch-mua-new-mail)
      (make-variable-buffer-local 'message-syntax-checks)
      (push '(illegible-text . disabled) message-syntax-checks)
      (message-goto-subject)
      (insert headline)
      (goto-char (point-max))
      ;(insert "\n")
      (mml-insert-part "text/calendar; method=REQUEST")
      (insert
       (org-icalendar-fold-string
        (with-temp-buffer
          (imip-write-element event)
          (buffer-string))))

      (message-goto-to)
      (while attendees
        (insert (car attendees))
        (setq attendees (cdr attendees))
        (when attendees (insert ", "))
        )
      )))


(provide 'org-notmuch-invite)
