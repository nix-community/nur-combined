#!/usr/bin/env bb

(require '[clojure.string :as str]
         '[clojure.java.shell :only [sh]])

(def workspace-count 5)

(print
 `(box
   :class "works"
   :orientation "v"
   :halign "center"
   :valign "start"
   :space-evenly "false"
   :spacing "-5"
   ~(for [wsp (range workspace-count)
          :let [focus? (-> (sh "hyprctl" "workspaces") :out)]]
      `(button
        :onclick "hyprctl dispatch "
        :class ~(str/join " " [])))))
