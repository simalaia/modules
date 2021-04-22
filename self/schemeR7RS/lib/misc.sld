;; -*- mode:scheme -*-

;; (delay expr) -> (λ () expr)
;; (force expr) -> (define (force expr) (expr))
;; (define-syntax delay (syntax-rules () ((delay expr) (λ () expr) )) )

(define-library (lib misc)
	(import (chibi) (chibi match)
		(scheme case-lambda)
					)
	(export dspl dsp wrtl wrt nl
		;;λ
		compose
		did? id
		fold foldr reduce filter
		rec receive inc dec
		)

	(begin
		(define (dspl . o) (for-each display o) (newline))
		(define (dsp . o) (for-each display o))
		(define (wrtl . o) (for-each write o) (newline))
		(define (wrt . o) (for-each write o))

		;; identity function, just because
		(define (id x) x)
		;; Truthy to actual truth value
		(define (did? x) (not (not x)))
		;;(define-syntax λ lambda)
		(define nl (string #\newline))
		
		(define (foldr f o)
			(match o
				((x y) (f x y) )
				((x y . z) (f x (foldr f (cons y z))) )
				(else (error "foldr broke") )) )
		
		(define (fold f o)
			(match o
				((x y) (f x y) )
				((x y . z) (fold f (cons (f x y) z)) )
				(else (error "fold broke") )) )

		(define (reduce f z o)
			(match o
				((x . xs) (reduce f (f z x) xs) )
				(() z )) )
		
			(define (filter f l)
				(let lop ( (l l) (r '()) )
					(cond
					 ((null? l) r)
					 ((f (car l)) (lop (cdr l) (cons (car l) r)) )
					 (else (lop (cdr l) r) )) ))

			;; Turn this into a macro?
			(define compose
				(case-lambda
					((f g) (lambda (a) (f (g a))) )
					(l (fold compose l) )) )

			;; Anonymous recursive functions
			(define-syntax rec
				(syntax-rules ( )
					((rec (n . v) . b)
					 (letrec ( (n (lambda v . b)) ) n) )
					((rec n e)
					 (letrec ( (n e) ) n) )) )

			(define-syntax receive
				(syntax-rules ()
					((receive formals expression body ...)
					 (call-with-values (lambda () expression)
						 (lambda formals body ...)))))
		
			(define (dec a) (- a 1) )
			(define (inc a) (+ a 1) )
		)
	)
