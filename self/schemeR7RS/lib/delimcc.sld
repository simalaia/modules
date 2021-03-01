;; -*- mode:scheme -*-

;; Oleg's delimcc library
(define-library (lib delimcc)
  (import (chibi)
          )
  (export shift reset
	  )
  (begin
    (define call/cc call-with-current-continuation)
    (define go #f)
    (define pstack '())

    (let ((v (call/cc
              (lambda (k)
                (set! go k)
                (k #f)))))
      (if v
          (let* ((r (v))
                  (h (car pstack))
                  (_ (set! pstack (cdr pstack))))
            (h r)) ))

      (define (reset* th)
        (call/cc (lambda (k) (set! pstack (cons k pstack)) (go th))) )

      (define (shift* f)
        (call/cc
          (lambda (k)
            (go (lambda ()
                  (f (lambda (v)
                      (call/cc
                        (lambda (k1)
                          (set! pstack (cons k1 pstack))
                          (k v))))))))))

      (define-syntax reset
        (syntax-rules ()
          ((_ ?e ?f ...) (reset* (lambda () ?e ?f ...)) )) )
      (define-syntax shift
        (syntax-rules ()
          ((_ ?k ?e ?f ...) (shift* (lambda (?k) ?e ?f ...)) )) )
    )
  )
