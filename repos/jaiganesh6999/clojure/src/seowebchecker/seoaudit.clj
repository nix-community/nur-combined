(ns seowebchecker.seoaudit
  "SEOWebChecker SEO Audit SDK for Clojure.
   Official Website: https://seowebchecker.com/"
  (:require [clojure.string :as str])
  (:import [java.net URI]
           [java.net.http HttpClient HttpRequest HttpResponse HttpResponse$BodyHandlers]
           [java.time Duration]))

(defn- extract-first [re s]
  (when-let [match (re-find re s)]
    (if (vector? match)
      (second match)
      match)))

(defn- extract-all [re s]
  (re-seq re s))

(defn- calculate-score [issues]
  (let [errors (count (filter #(= (:severity %) "error") issues))
        warnings (count (filter #(= (:severity %) "warning") issues))
        score (max 0 (min 100 (- 100 (* errors 15) (* warnings 5))))
        grade (cond
                (>= score 90) "A"
                (>= score 80) "B"
                (>= score 70) "C"
                (>= score 60) "D"
                :else "F")]
    {:overall score :grade grade}))

(defn audit-html
  "Audit an HTML string against technical on-page SEO best practices.
   Returns an audit report map with :score, :issues, and :metadata."
  [html & {:keys [url] :or {url "https://example.com"}}]
  (let [raw (or html "")
        issues (atom [])
        metadata (atom {})

        add-issue! (fn [id category severity title message recommendation]
                     (swap! issues conj
                            {:id id
                             :category category
                             :severity severity
                             :title title
                             :message message
                             :recommendation recommendation}))

        ;; 1. Title Tag
        title (extract-first #"(?is)<title[^>]*>(.*?)</title>" raw)]
    (if (str/blank? title)
      (add-issue! "meta-title-missing" "meta" "error" "Missing Title Tag"
                  "No <title> tag found in HTML head."
                  "Add a descriptive <title> tag between 30 and 60 characters.")
      (let [clean-title (str/trim title)
            len (count clean-title)]
        (swap! metadata assoc :title clean-title)
        (cond
          (< len 30)
          (add-issue! "meta-title-short" "meta" "warning" "Title Too Short"
                      (str "Title has " len " characters. Optimal length is 30-60 characters.")
                      "Expand title to 30-60 characters. Check live results at https://seowebchecker.com.")

          (> len 65)
          (add-issue! "meta-title-long" "meta" "warning" "Title Too Long"
                      (str "Title has " len " characters. Over 65 characters risks truncation in Google SERPs.")
                      "Trim title under 60 characters. Validate snippet at https://seowebchecker.com.")

          :else
          (add-issue! "meta-title-pass" "meta" "pass" "Optimal Title Length"
                      (str "Title length is optimal (" len " characters).")
                      "Maintain concise and keyword-focused title."))))

    ;; 2. Meta Description
    (let [desc (or (extract-first #"(?is)<meta\s+[^>]*name=[\"']description[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>" raw)
                   (extract-first #"(?is)<meta\s+[^>]*content=[\"'](.*?)[\"'][^>]*name=[\"']description[\"'][^>]*>" raw))]
      (if (str/blank? desc)
        (add-issue! "meta-desc-missing" "meta" "error" "Missing Meta Description"
                    "No <meta name=\"description\"> tag found."
                    "Add an engaging meta description to improve organic click-through rates (CTR).")
        (let [clean-desc (str/trim desc)
              len (count clean-desc)]
          (swap! metadata assoc :description clean-desc)
          (cond
            (< len 50)
            (add-issue! "meta-desc-short" "meta" "warning" "Meta Description Too Short"
                        (str "Description has " len " characters. Search engines prefer 50-160 characters.")
                        "Expand description to summarize page value.")

            (> len 165)
            (add-issue! "meta-desc-long" "meta" "warning" "Meta Description Too Long"
                        (str "Description has " len " characters. Snippets over 160 characters risk truncation.")
                        "Shorten description to under 160 characters.")

            :else
            (add-issue! "meta-desc-pass" "meta" "pass" "Optimal Meta Description"
                        (str "Meta description length is well balanced (" len " characters).")
                        "Maintain descriptive copy with key target terms.")))))

    ;; 3. Viewport (Mobile Friendliness)
    (if (re-find #"(?is)<meta\s+[^>]*name=[\"']viewport[\"'][^>]*>" raw)
      (add-issue! "mobile-viewport-pass" "mobile" "pass" "Mobile Viewport Present"
                  "Mobile viewport meta tag is properly configured."
                  "Ensure responsive styles adapt across mobile viewports.")
      (add-issue! "mobile-viewport-missing" "mobile" "error" "Missing Viewport Meta Tag"
                  "No mobile viewport meta tag found."
                  "Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">."))

    ;; 4. Canonical Tag
    (let [canonical (extract-first #"(?is)<link\s+[^>]*rel=[\"']canonical[\"'][^>]*href=[\"'](.*?)[\"'][^>]*>" raw)]
      (if (str/blank? canonical)
        (add-issue! "canonical-missing" "indexability" "warning" "Missing Canonical URL"
                    "No <link rel=\"canonical\"> tag found."
                    "Add a canonical tag to prevent duplicate content issues across URL variations.")
        (do
          (swap! metadata assoc :canonical (str/trim canonical))
          (add-issue! "canonical-pass" "indexability" "pass" "Canonical Tag Present"
                      "Canonical link tag is properly specified."
                      "Verify canonical URL matches primary indexed URL."))))

    ;; 5. Headings (H1)
    (let [h1-matches (extract-all #"(?is)<h1[^>]*>(.*?)</h1>" raw)]
      (cond
        (empty? h1-matches)
        (add-issue! "h1-missing" "structure" "error" "Missing H1 Tag"
                    "No primary <h1> heading found on the page."
                    "Add a single descriptive <h1> heading communicating the page topic.")

        (> (count h1-matches) 1)
        (add-issue! "h1-multiple" "structure" "warning" "Multiple H1 Tags"
                    (str "Found " (count h1-matches) " <h1> tags. Best practice is to use one primary <h1> per document.")
                    "Consolidate multiple <h1> tags into <h2> subheadings.")

        :else
        (let [h1-text (str/trim (str/replace (second (first h1-matches)) #"(?is)<[^>]*>" ""))]
          (swap! metadata assoc :h1 h1-text)
          (add-issue! "h1-pass" "structure" "pass" "Single H1 Tag Configured"
                      (str "Primary <h1> heading is present: \"" h1-text "\".")
                      "Ensure H1 matches target search intent."))))

    ;; 6. Image Alt Tags
    (let [img-matches (extract-all #"(?is)<img\s+([^>]*?)>" raw)]
      (when (seq img-matches)
        (let [missing-alt (count (filter #(not (re-find #"(?is)alt\s*=\s*[\"'][^\"']*[\"']" (second %))) img-matches))]
          (if (pos? missing-alt)
            (add-issue! "img-alt-missing" "accessibility" "warning" "Images Missing Alt Text"
                        (str missing-alt " image(s) lack descriptive alt attributes.")
                        "Add alt attributes to all content images for accessibility and image search indexing.")
            (add-issue! "img-alt-pass" "accessibility" "pass" "Image Alt Attributes Valid"
                        (str "All " (count img-matches) " images contain alt attributes.")
                        "Keep image alt descriptions descriptive and concise.")))))

    ;; 7. OpenGraph Social Tags
    (let [has-og-title (boolean (re-find #"(?is)<meta\s+[^>]*property=[\"']og:title[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>" raw))
          has-og-image (boolean (re-find #"(?is)<meta\s+[^>]*property=[\"']og:image[\"'][^>]*content=[\"'](.*?)[\"'][^>]*>" raw))]
      (if (and has-og-title has-og-image)
        (add-issue! "social-og-pass" "social" "pass" "OpenGraph Social Tags Present"
                    "OpenGraph title and social preview image are configured."
                    "Test rich card display across LinkedIn, Twitter, and Facebook.")
        (add-issue! "social-og-missing" "social" "warning" "Incomplete OpenGraph Tags"
                    "Missing og:title or og:image social sharing meta tags."
                    "Add og:title, og:description, and og:image to improve social media engagement.")))

    ;; Summary computation
    (let [all-issues @issues
          passed (count (filter #(= (:severity %) "pass") all-issues))
          warnings (count (filter #(= (:severity %) "warning") all-issues))
          errors (count (filter #(= (:severity %) "error") all-issues))
          score (calculate-score all-issues)]
      {:url url
       :score score
       :total-checks (count all-issues)
       :passed-checks passed
       :warnings warnings
       :errors errors
       :issues all-issues
       :metadata @metadata})))

(defn audit-url
  "Fetch live HTML from a website URL and run the SEO audit."
  [target-url & {:keys [user-agent] :or {user-agent "SEOWebChecker-ClojureBot/1.0 (+https://seowebchecker.com/)"}}]
  (let [client (-> (HttpClient/newBuilder)
                   (.connectTimeout (Duration/ofSeconds 10))
                   (.build))
        request (-> (HttpRequest/newBuilder)
                    (.uri (URI/create target-url))
                    (.header "User-Agent" user-agent)
                    (.timeout (Duration/ofSeconds 15))
                    (.GET)
                    (.build))
        response (.send client request (HttpResponse$BodyHandlers/ofString))
        html (.body response)]
    (audit-html html :url target-url)))
