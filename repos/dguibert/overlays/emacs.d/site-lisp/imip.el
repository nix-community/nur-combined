;; curl -O https://raw.githubusercontent.com/larkery/emacs/master/site-lisp/imip.el
;; provides icalendar message-based interoperability protocol
;; like rfc6047 but probably full of bugs

(require 'icalendar)

(defun imip-respond (invitation addresses response-string)
  "Given the icalendar object for invitation, produce a new one which responds appropriately."
  ;; According to RFC5546 p25, we can send a reply that contains just:
  ;; - method (vevent attendee dtstamp organizer uid sequence)+
  ;; however, outlook doesn't support this because it's stupid
  (let* ((invitation-contents (nth 3 invitation))
         (address-re (rx-to-string `(| ,@addresses)))
         (dtstamp (format-time-string "%Y%m%dT%H%M%SZ" nil t))
         events)

    (dolist (item invitation-contents)
      (cl-case (car item)
        (VTIMEZONE
         (push item events))

        (VEVENT
         (let* ((event-things (nth 2 item))
                (organizer (assq 'ORGANIZER event-things))
                (sequence (assq 'SEQUENCE event-things))
                (uid (assq 'UID event-things))
                attendees
                misc)
           (dolist (thing event-things)
             (cl-case (car thing)
               (ATTENDEE
                (when (string-match-p address-re (nth 2 thing))
                  (push `(ATTENDEE (PARTSTAT ,response-string) ,(nth 2 thing)) attendees)))
               ((DTSTART DTEND)
                (push thing misc))))

           (push `(VEVENT nil (,organizer
                               ,sequence
                               ,uid
                               (DTSTAMP nil ,dtstamp)
                               ,@attendees
                               ,@misc))
                 events))
         )))

    `(VCALENDAR nil
                     ((METHOD nil "REPLY")
                      (PRODID nil "Emacs")
                      (VERSION nil "2.0"))
                     ,events)))


(defun imip-write-element (icalendar)
  "This is the inverse of icalendar--read-element from icalendar.el.
  It doesn't do stupid icalendar wrappning, nor does it put in CRLFs"

  (cond
   ((symbolp (car icalendar))
    (let ((element-name (nth 0 icalendar))
          (element-attrs (nth 1 icalendar))
          (element-properties (nth 2 icalendar))
          (element-children (nth 3 icalendar)))
      (insert (format "BEGIN:%s" element-name))
      (while element-attrs
        (insert ";")
        (insert (format "%s=%s" (car element-attrs) (cadr element-attrs)))
        (setq element-attrs (cddr element-attrs)))
      (insert "\n")
      (dolist (prop element-properties)
        (let ((prop-name (nth 0 prop))
              (prop-attrs (nth 1 prop)) ;; WHY?
              (prop-val (nth 2 prop)))
          (insert (format "%s" prop-name))
          (while prop-attrs
            (insert ";")
            (insert (format "%s=%s" (car prop-attrs) (cadr prop-attrs)))
            (setq prop-attrs (cddr prop-attrs)))
          (insert (format ":%s\n" prop-val))))
      (dolist (child element-children)
        (imip-write-element child))
      (insert (format "END:%s\n" element-name))))
   ((listp (car icalendar))
    (dolist (sub-element icalendar)
      (imip-write-element sub-element)))))

(provide 'imip)
