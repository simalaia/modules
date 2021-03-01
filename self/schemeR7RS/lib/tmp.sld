;; -*- mode:scheme -*-

;; Attempts at implementing the clojure transducer idea

(define-library (lib tmp)
  (import (chibi) (chibi match)
          (scheme case-lambda) (only (scheme base) define-record-type)
          )
  (export list-transduce vector-transduce tmap rcons
	  )
  (begin
    (define-record-type <reduced> (reduced val) reduced? (val unreduce))
    (define-record-type <nothing> (make-nothing) nothing?)
    (define nothing (make-nothing))

    (define (ensure-reduced x) (if (reduced? x) x (reduced x)))

    (define (preserving-reduced reducer)
      (lambda (a b)
        (let ( (return (reducer a b)) )
          (if (reduced? return) (reduced return) return) )) )

    (define (list-reduce f id lst)
      (if (null? lst) id
        (let ((v (f id (car lst))))
          (if (reduced? v) (unreduce v) (list-reduce f v (cdr lst))))))

    (define (make-col-reducer col-len col-ref)
      (lambda (f id col)
        (let ((len (col-len col)))
          (let lop ((i 0) (acc id))
            (if (= i len) acc
              (let ((acc (f acc (col-ref col i))))
                (if (reduced? acc) (unreduce acc) (lop (+ i 1) acc))))))))

    (define vector-reduce (make-col-reducer vector-length vector-ref))

    (define rcons
      (case-lambda
        (() '() )
        ((lst) (reverse! lst) )
        ((lst x) (cons x lst) )) )

    (define (make-col-transduce reducer)
      (letrec
        ((TR
          (case-lambda
            ((xform f col) (TR xform f (f) col) )
            ((xform f init col)
              (let* ((xf (xform f)) (result (reducer xf init col)))
                (xf result) ) )) ))
        TR ))

    (define list-transduce (make-col-transduce list-reduce))
    (define vector-transduce (make-col-transduce vector-reduce))

    (define (tmap f)
      (lambda (reducer)
        (case-lambda
          (() (reducer) )
          ((result) (reducer result) )
          ((result input) (reducer result (f input)) )) ))

    (define (reduce f z o)
      (match o
        ((x . xs) (reduce f (f z x) xs) )
        (() z )) )

    (define (compose . functions)
      (define (make-chain thunk chain)
        (lambda args
          (call-with-values (lambda () (apply thunk args)) chain)))
      (if (null? functions) values
        (reduce make-chain (car functions) (cdr functions))))

    
    )
  )
