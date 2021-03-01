;; -*- mode:scheme -*-

;; Macro writing library, most from Oleg

(define-library (lib macros)
  (import (chibi)
          (lib misc)
          )
  (export transformer make-sc
    mtrace
    symbol?? id-memv??
    k!id k!reverse
	  )
  (begin
    (define transformer sc-macro-transformer)
    (define make-sc make-syntactic-closure)
    
    (define-syntax mtrace
      (syntax-rules ()
        ((mtrace x)
         (begin (display "Trace: ") (write 'x) (newline) (newline) x) )) )

    (define-syntax symbol??
      (syntax-rules ()
        ((symbol?? (x . y) kt kf) kf ) ;; A pair
        ((symbol?? #(x ...) kt kf) kf ) ;; A vector
        ((symbol?? maybe-symbol kt kf)
          (let-syntax
            ((test
              (syntax-rules ()
                ((test maybe-symbol t f) t )
                ((test x t f) f )) ))
            (test abracadabra kt kf)) )) )

    ;; macro-expand-time memv function for identifiers
    (define-syntax id-memv??
      (syntax-rules ()
        ((id-memv?? form (id ...) kt kf)
          (let-syntax
            ((test
              (syntax-rules (id ...)
                ((test id _kt _kf) _kt) ...
                ((test otherwise _kt _kf) _kf )) ))
            (test form kt kf)))))

    (define-syntax k!id   ;; identity
      (syntax-rules ()
        ((k!id x) x )) )

    (define-syntax k!reverse
      (syntax-rules (!)
        ((k!reverse acc () (k-head ! . k-args))
          (k-head acc . k-args))
        ((k!reverse acc (x . rest) k)
          (k!reverse (x . acc) rest k))))
    )
  )
