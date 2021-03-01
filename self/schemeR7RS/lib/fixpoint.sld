;; -*- mode:scheme -*-

;; Fix point experiments, on hold while I work on my education

(define-library (lib fixpoint)
  (import (chibi)
          )
  (export U Y* Y
	  )
  (begin
    ;; https://jwodder.freeshell.org/lambda.html
    ;; Zgv = g(Zg)v           ;; Applicative combinator
    ;; Z = λf.(λx.f(λv.xxv))(λx.f(λv.xxv)) ;; likewise
    ;; Applicative fixed point:
    (define U (λ (u) (u u)))  ;; self-application combinator
    (define Y (λ (f) (U (λ (p) (λ (x) ((f (p p)) x))))))

    ;; Oleg's strict Y* combinator
    (define (Y* . l)
      (U (λ (p) (map (λ (li) (λ x (apply (apply li (p p)) x))) l))))

    ;; The above can be expressed in pure lambda like so:
    (define TRUE (λ (x) (λ (y) x)))
    (define FALSE (λ (x) (λ (y) y)))
    (define CONS (λ (x) (λ (y) (λ (f) ((f x) y)))))
    (define CAR (λ (p) (p TRUE)))
    (define CDR (λ (p) (p FALSE)))
    (define NIL (λ (x) TRUE))
    (define NULL? (λ (p) (p (λ (x) (λ (y) FALSE)))))

    (define APPLY
      (Y (λ (g) (λ (f) (λ (x) ((((((((NULL x) f) g) f) CAR) x) CDR) x))))))

    ;; (define MAP (Y (λ (g) (λ (f) (λ (x) (NULL (x (NIL
    )
  )
