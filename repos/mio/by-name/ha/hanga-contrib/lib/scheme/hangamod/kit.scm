(library (hangamod kit)
  (export kit-fields kit-get kit-flag kit-f32 kit-bool)
  (import (scheme base) (scheme char) (scheme inexact))

  (define (delim? c)
    (or (char=? c #\;) (char=? c #\newline)))

  (define (trim s)
    (let* ((n (string-length s))
           (a (let loop ((i 0))
                (if (and (< i n) (char-whitespace? (string-ref s i)))
                    (loop (+ i 1))
                    i)))
           (b (let loop ((i n))
                (if (and (> i a) (char-whitespace? (string-ref s (- i 1))))
                    (loop (- i 1))
                    i))))
      (substring s a b)))

  (define (kit-fields text)
    (let ((n (string-length text)))
      (let loop ((i 0) (out '()))
        (if (>= i n)
            (reverse out)
            (let ((j (let scan ((k i))
                       (if (or (>= k n) (delim? (string-ref text k)))
                           k
                           (scan (+ k 1))))))
              (let ((rec (trim (substring text i j))))
                (let ((next (if (< j n) (+ j 1) n)))
                  (if (or (string=? rec "")
                          (and (> (string-length rec) 0)
                               (char=? (string-ref rec 0) #\#)))
                      (loop next out)
                      (let ((eq (let find ((k 0))
                                  (cond
                                   ((>= k (string-length rec)) #f)
                                   ((char=? (string-ref rec k) #\=) k)
                                   (else (find (+ k 1)))))))
                        (if eq
                            (loop next
                                  (cons (cons (trim (substring rec 0 eq))
                                              (trim (substring rec (+ eq 1)
                                                               (string-length rec))))
                                        out))
                            (loop next out)))))))))))

  (define (kit-get text key)
    (let loop ((fs (kit-fields text)))
      (cond
       ((null? fs) #f)
       ((string=? (car (car fs)) key) (cdr (car fs)))
       (else (loop (cdr fs))))))

  (define (kit-flag value)
    (let ((v (list->string
              (map char-downcase (string->list (trim value))))))
      (or (string=? v "1")
          (string=? v "true")
          (string=? v "yes")
          (string=? v "on"))))

  (define (kit-f32 text key default)
    (let ((raw (kit-get text key)))
      (if (not raw)
          default
          (let ((n (string->number raw)))
            (if n (inexact n) default)))))

  (define (kit-bool text key)
    (let ((raw (kit-get text key)))
      (kit-flag (if raw raw "0")))))
