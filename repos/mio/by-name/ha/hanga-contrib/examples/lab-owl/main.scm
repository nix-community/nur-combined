;; Quiet checkerboard for trying a Hoot (Scheme → WasmGC) pack.
;; Hoot 0.9 is not a WASI/WIT guest; this file is compiled with `hoot compile`.
(import (scheme base)
        (scheme write)
        (hangamod kit)
        (hangamod catalog)
        (hangamod wire))

(define catalog "air,owl,perch")
(define bus-topics "ping,name,catalog,gravity,has,methods,voxel")

(define (query-voxel x y z)
  (cond
   ((< y 0) 1)
   ((= y 0) (if (even? (+ x z)) 1 2))
   (else 0)))

(define (gravity)
  "kind=down;g=9.81;jump=5;walk=10")

(unless (string=? (catalog-name (catalog-parse catalog) (query-voxel 0 0 0)) "owl")
  (error "lab_owl voxel"))
(unless (kit-flag "1")
  (error "lab_owl kit"))
(let ((probe (wire-voxel-probe "owl" #f)))
  (unless (string=? (wire-bag-text probe "name") "owl")
    (error "lab_owl wire")))
(display "lab_owl ready")
(newline)
(list catalog bus-topics (gravity) (query-voxel 1 0 1))
