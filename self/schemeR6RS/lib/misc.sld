;; -*- mode:scheme -*-
;; Library of useful utility functions

(library (lib misc)
	(export dsp dspln wrt wrtln foldr foldr compose pipe c-e c-p mtrace)
	(import (rnrs))

	;; Less annoying display functions
	(define (dsp	 . o) (for-each display o))
	(define (dspln . o) (for-each display o) (newline))
	(define (wrt	 . o) (for-each write	 o))
	(define (wrtln . o) (for-each write	 o) (newline))

	(define (foldr f o)
		(letrec (
				(F (lambda (x y z)
					(cond
			 			((null? z) (f x y) )
			 			(else (f x (F y (car z) (cdr z))) )) )) )
			(if (or (not (list? o)) (null? o) (null? (cdr o)))
				(error 'meh "foldr hates you")
				(F (car o) (cadr o) (cddr o))) ))

	(define (foldl f o)
		(letrec (
				(F (lambda (x y z)
					(cond
						((null? z) (f x y) )
						(else (F (f x y) (car z) (cdr z)) )) )) )
			(if (or (not (list? o)) (null? o) (null? (cdr o)))
				(error 'meh "foldl hates you")
				(F (car o) (cadr o) (cddr o))) ))
	
	(define compose
		(case-lambda
			((f g) (lambda (a) (f (g a))) )
			(l (foldr compose l) )) )
	
	(define pipe
		(case-lambda
			((f g) (lambda (a) (g (f a))) )
			(l (foldl pipe l) )) )

	;; Check expect and check predicate
	(define-syntax c-e
		(syntax-rules ()
			((c-e n e)
				(let ( (r (equal? n e)) )
					(dspln 'n)
					(dspln "\tresult: " n)
					(dspln "\texpect: " e)
					(dspln "\tcheck: " r)) )) )
	
	(define-syntax c-p
		(syntax-rules ()
			((c-p n p r)
				(let ( (x (p n r)) )
					(dspln 'n)
					(dspln "\tresult: " n)
					(dspln "\texpect: " r)
					(dspln "\tcheck: " x)))))

	;; Macro trace from Oleg
	(define-syntax mtrace
		(syntax-rules ()
			((mtrace x)
				(begin
					(dsp "Trace: ") (wrtln 'x)
					x) )) )
	)
