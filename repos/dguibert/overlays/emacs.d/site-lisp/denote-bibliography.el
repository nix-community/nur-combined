;; https://www.scss.tcd.ie/~sulimanm/posts/denote-bibliography.html
(defun namilus-denote-org-capture-biblio ()
  "Ask the user for a bibtex entry, title, and keywords, and creates a denote note template with:

1. The bibtex included inside an org bibtex source block.

2. The keyword \"biblio\" and the bibtex entry's sanitised key as
part of the denote file's tags. If the bibtex entry entered by
the user is empty or doesn't match the regexp, only the
\"biblio\" keyword is added, along with whatever other keywords
entered by the user."
  (let* ((bibtex (namilus-denote-bibtex-prompt))
         (title (denote-title-prompt (namilus-denote-bibtex-title bibtex)))
         (keywords (append (denote-keywords-prompt) (namilus-denote-biblio-keywords bibtex)))
         (date (current-time))
         (front-matter (denote--format-front-matter title date keywords (format-time-string denote-id-format date) "" 'org)))
    (setq denote-last-path
          (denote-format-file-name (file-name-as-directory (denote-directory))
                                   (format-time-string denote-id-format)
                                   keywords title ".org" nil))

    (denote--keywords-add-to-history keywords)
    (concat front-matter (namilus-denote-bibtex-org-block bibtex))))

(defun namilus-denote-bibtex-prompt (&optional default-bibtex)
  "Ask the user for a bibtex entry. Returns the sanitised
version. See `namilus-denote-sanitise-bibtex' for details."
  (let* ((def default-bibtex)
         (format (if (and def (not (string-empty-p def)))
                     (format "Bibtex [%s]: " def)
                   "Bibtex: "))
         (sanitised-bibtex (namilus-denote-sanitise-bibtex (read-string format nil nil def))))
    (if sanitised-bibtex
        sanitised-bibtex
      (error "Invalid BiBTeX"))))


(defun namilus-denote-sanitise-bibtex (bibtex)
  "Returns a santised version of BIBTEX. Sanitisation entails remove
all non alpha-numeric characters from the bibtex key, and
 returning this updated bibtex entry. If BIBTEX is not a valid
 bibtex entry, returns nil."
  (when (string-match "@.*{\\(.*\\)," bibtex)
    (let* ((key (match-string-no-properties 1 bibtex))
           (sanitised-key (replace-regexp-in-string "[^A-Za-z0-9]" "" key)))
      (replace-regexp-in-string key sanitised-key bibtex))))



(defun namilus-denote-bibtex-key (bibtex)
  "Returns the bibtex key from BIBTEX."
  (when (string-match "@.*{\\(.*\\)," bibtex)
    (match-string-no-properties 1 bibtex)))

(defun namilus-denote-bibtex-title (bibtex)
  "Returns the bibtex title from BIBTEX."
  (when (string-match "\\s *title\\s *=\\s *{\\(.*\\)}," bibtex)
    (match-string-no-properties 1 bibtex)))


(defun namilus-denote-biblio-keywords (bibtex)
  "Returns a list of strings \"biblio\" and the key from the BIBTEX
entry, otherwise, just returns a list consisting of the string
 \"biblio\"."
  (let ((bibtex-key (namilus-denote-bibtex-key bibtex)))
    (if bibtex-key
        `("biblio" ,bibtex-key)
      '("biblio"))))

(defun namilus-denote-bibtex-org-block (bibtex)
  "Returns a string representing an org `bibtex' source block
encompassing BIBTEX, a string of a bibtex entry."
  (concat "#+begin_src bibtex\n" bibtex "\n#+end_src"))

(add-to-list 'org-capture-templates
             '("B" "Bibliography (with Denote) BibTeX" plain
               (file denote-last-path)
                      #'namilus-denote-org-capture-biblio
                      :no-save t
                      :immediate-finish nil
                      :kill-buffer t
                      :jump-to-captured nil))

(defun namilus-denote-biblio-read-bibtex (file)
  "Reads the bibtex entry from a given Denote FILE. Does so by
searching for a org bibtex source block and returns the contents
therein."
  (with-temp-buffer
    (insert-file-contents file)
    (let ((contents (buffer-string)))
      (when (string-match "#\\+begin_src.*bibtex\\(\\(.*\n\\)*\\)#\\+end_src" contents)
        (match-string-no-properties 1 contents)))))


(defun namilus-denote-generate-bibliography (denote-biblio-files bibliography-file)
  "Writes the org bibtex source blocks located in each of
DENOTE-BIBLIO-FILES to BIBLIOGRAPHY-FILE."
  (with-temp-file bibliography-file
    (dolist (file denote-biblio-files)
      (let ((bibtex (namilus-denote-biblio-read-bibtex file)))
        (if bibtex
            (insert bibtex))))))

(defun namilus-denote-bibliography-file-prompt (&optional default-bibliography-file)
  "Ask the user for a bibliography file."
  (let* ((def default-bibliography-file)
         (format (if (and def (not (string-empty-p def)))
                     (format "Bibliography file [%s]: " def)
                   "Bibliography file: ")))
    (expand-file-name (read-file-name format nil def))))


(defun namilus-denote-dired-generate-bibliography-from-marked ()
  (interactive)
  (namilus-denote-generate-bibliography (dired-get-marked-files)
                                        (namilus-denote-bibliography-file-prompt)))

(provide 'denote-bibliography)
