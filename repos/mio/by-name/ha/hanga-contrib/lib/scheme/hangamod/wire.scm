(library (hangamod wire)
  (export wire-text wire-voxel-probe wire-as-text wire-bag-text wire-bag-flag)
  (import (scheme base))

  (define (wire-text value)
    (list 'text value))

  (define (wire-voxel-probe name edit)
    (list 'bag
          (list (cons "name" (list 'text name))
                (cons "edit" (list 'flag edit)))))

  (define (wire-as-text w)
    (and (pair? w) (eq? (car w) 'text) (cadr w)))

  (define (wire-bag-text w key)
    (and (pair? w)
         (eq? (car w) 'bag)
         (let loop ((fs (cadr w)))
           (cond
            ((null? fs) #f)
            ((and (string=? (car (car fs)) key)
                  (eq? (car (cdr (car fs))) 'text))
             (cadr (cdr (car fs))))
            (else (loop (cdr fs)))))))

  (define (wire-bag-flag w key)
    (and (pair? w)
         (eq? (car w) 'bag)
         (let loop ((fs (cadr w)))
           (cond
            ((null? fs) #f)
            ((string=? (car (car fs)) key)
             (let ((atom (cdr (car fs))))
               (cond
                ((eq? (car atom) 'flag) (cadr atom))
                ((and (eq? (car atom) 'int) (= (cadr atom) 1)) #t)
                (else #f))))
            (else (loop (cdr fs))))))))
