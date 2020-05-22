;;; publish.el --- Publish home project -*- lexical-binding: t; -*-
;; Author: Vincent Demeester <vincent@sbr.pm>

;;; Commentary:
;; This script will convert the org-mode files in this directory into
;; html.

;;; Code:
(require 'package)
(require 'publish-common)

;; OrgPublishProjects
(setq org-publish-project-alist
      `(("configurations"
         :base-directory "docs"
         :base-extension "org"
         :recursive t
         :publishing-function org-html-publish-to-html
         :publishing-directory "../www/public/configurations"
         :exclude ,(regexp-opt '("README.org" "draft"))
         :auto-sitemap t
         :sitemap-filename "sitemap.org"
         :sitemap-title "Configurations"
         ;;:sitemap-format-entry sbr/org-sitemap-format-entry
         :sitemap-style tree
         :sitemap-sort-files anti-chronologically
         ;;:sitemap-function sbr/org-publish-sitemap
         :with-footnotes t
         :with-toc nil
         :with-drawers t
         :html-head-include-scripts nil
         :html-head-include-default-style nil
         :html-head ,sbr-website-html-head
         :html-preamble sbr-website-html-preamble
         :html-postamble ,sbr-website-html-postamble)
        ("images"
         :base-directory "docs/images"
         :base-extension ,site-attachments
         :publishing-directory "../www/public/configurations/images"
         :publishing-function org-publish-attachment
         :recursive t)
        ("assets"
         :base-directory "docs/assets"
         :base-extension ,site-attachments
         :publishing-directory "../www/public/configurations/assets"
         :publishing-function org-publish-attachment
         :recursive t)
        ("all" :components ("configurations" "images" "assets"))))
;; -OrgPublishProjects

(provide 'publish)
;;; publish.el ends here
