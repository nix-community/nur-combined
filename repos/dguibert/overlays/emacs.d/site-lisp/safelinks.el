;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             Microsoft safelinks decoder                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'url-parse)
(defun my-decode-safelink (url)
  ;; (print url)
  "Given a url string this function returns the corresponding decoded url"
  (if (string-match-p (regexp-quote "safelinks.protection") url)
      (let* ((query (url-filename (url-generic-parse-url url)))
             (url (cadr (assoc ".*/?url" (url-parse-query-string query) (lambda (pat x) (string-match-p x pat)))))
             (path (replace-regexp-in-string "3Dhttps" "https" (url-unhex-string url))))
        (url-encode-url (replace-regexp-in-string (rx "/" (>= 20 (any "#$%&*^@"))) "" path)))
    url))

;; Main function
(defun unsafelinks ()
  "This function filters MS safelinks from a message buffer"
  (interactive)
  (let (url current-start-pos next-change-pos)
    (save-excursion
      (goto-char (point-min))
      (let ((inhibit-read-only t)
            (simple-url-regexp "https?://") urls)
        (search-forward-regexp "^$" nil t)
        (setq next-change-pos (or (next-single-property-change (point) 'shr-url)
                                  (point-max)))
        (goto-char next-change-pos)

        (while (< next-change-pos (point-max))
          (setq url               (get-text-property (point) 'shr-url)
                current-start-pos (point)
                next-change-pos   (or (next-single-property-change (point) 'shr-url)
                                      (point-max)))
          (when url
            (setq text (buffer-substring-no-properties current-start-pos (point)))
            ;; edit widget URLs
            (add-text-properties current-start-pos next-change-pos
                                 (list 'shr-url (my-decode-safelink url)
                                       'help-echo (my-decode-safelink url)))
            ;; edit text URLs
            (when-let ((link (thing-at-point 'url))
                       (bounds (thing-at-point-bounds-of-url-at-point)))
              (delete-region (car bounds) (cdr bounds))
              (insert (my-decode-safelink url)))
            )
          (goto-char next-change-pos))
        (remove-overlays)
        (mu4e~view-activate-urls)
        (set-buffer-modified-p nil)))))

(defun unsafelinks-advice (msg)
  (unsafelinks))
(advice-add #'mu4e~view-render-buffer :after #'unsafelinks-advice)
