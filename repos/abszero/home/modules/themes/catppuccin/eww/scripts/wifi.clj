#!/usr/bin/env bb

(require '[babashka.process :as p])
(import (java.util Scanner))

;; Print initial value of Wi-Fi
(->> (p/sh "nmcli --fields NAME,TYPE connection show --active")
     :out
     (re-find #".*(?=\s+wifi)")
     println)

(def scanner
  (-> (p/process "nmcli monitor")
      :out
      Scanner.))

(while true
  (when (.hasNextLine scanner)
    (condp re-find (.nextLine scanner)
      #"(?<=^').*(?=' is now the primary connection$)" :>> println
      #"^There's no primary connection$" :>> (fn [_] (println nil))
      nil)))
