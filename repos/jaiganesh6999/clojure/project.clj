(defproject net.clojars.seoaitools/seowebchecker-seoaudit-sdk "1.0.0"
  :description "Lightweight open-source client SDK and utility suite for website SEO audits, on-page analysis, and Core Web Vitals checks."
  :url "https://seowebchecker.com/"
  :license {:name "MIT License"
            :url "https://opensource.org/licenses/MIT"}
  :scm {:name "git"
        :url "https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk"}
  :dependencies [[org.clojure/clojure "1.11.1"]]
  :deploy-repositories [["clojars" {:url "https://repo.clojars.org"
                                    :username :env/CLOJARS_USERNAME
                                    :password :env/CLOJARS_PASSWORD
                                    :sign-releases false}]]
  :profiles {:dev {:dependencies []}})
