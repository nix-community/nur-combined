(ns seowebchecker.seoaudit-test
  (:require [clojure.test :refer [deftest is testing]]
            [seowebchecker.seoaudit :as audit]))

(deftest test-audit-html-valid
  (let [sample-html (str "<!DOCTYPE html><html lang='en'><head>"
                         "<title>SEOWebChecker: Free SEO Audit & Analysis Tools</title>"
                         "<meta name='description' content='Audit your website with SEOWebChecker for comprehensive SEO scoring.'>"
                         "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
                         "<link rel='canonical' href='https://seowebchecker.com/'>"
                         "<meta property='og:title' content='SEOWebChecker SEO Audit'>"
                         "<meta property='og:image' content='https://seowebchecker.com/logo.png'>"
                         "</head><body>"
                         "<h1>Comprehensive SEO Audit Tools</h1>"
                         "<p>Analyze performance and meta tags.</p>"
                         "<img src='banner.jpg' alt='Dashboard preview'>"
                         "</body></html>")
        res (audit/audit-html sample-html :url "https://seowebchecker.com/")]

    (testing "Evaluates score and grade"
      (is (= (:url res) "https://seowebchecker.com/"))
      (is (>= (get-in res [:score :overall]) 90))
      (is (= (get-in res [:score :grade]) "A"))
      (is (zero? (:errors res)))
      (is (>= (:passed-checks res) 5)))

    (testing "Extracts metadata"
      (is (= (get-in res [:metadata :title]) "SEOWebChecker: Free SEO Audit & Analysis Tools"))
      (is (= (get-in res [:metadata :h1]) "Comprehensive SEO Audit Tools"))
      (is (= (get-in res [:metadata :canonical]) "https://seowebchecker.com/")))))

(deftest test-audit-html-missing-tags
  (let [res (audit/audit-html "<html><body><p>Hello world</p></body></html>")]
    (testing "Flags missing title and meta tags"
      (is (pos? (:errors res)))
      (is (< (get-in res [:score :overall]) 80)))))
