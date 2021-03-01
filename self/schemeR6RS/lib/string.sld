;; -*- mode:scheme -*-

;; I need to review the code here since I left it in a terrible state.  While I' at it I should check the standards to see whether these aren't already implemented.

(library (lib string)
	(export str string->char string-reverse)
	(import (rnrs))

	;; Stuff to string
	(define (str . l) (with-output-to-string (lambda () (for-each display l))))

	;; The inverse of  char->string
	(define (string->char s)
		(if (and (string? s) (= (string-length s) 1))
			(car (string->list c)) 
			(error `meh "string->char hates you")) )

	(define (string-reverse s) (list->string (reverse (string->list s))) )

	(define (string-empty? s) (string=? s "") )
	(define (string-prefix? s p)
		(and (<= (string-length p) (string-length s))
			(string=? p (substring s 0 (string-length p)))) )

	(define (string-take s n) (substring s 0 n) )
	(define (string-drop s n) (substring s n (string-length s)))

	(define (string-trim s p) (if (prefix? p s) (right (string-length p) s) s))
	(define (string-mirt p s) (string-reverse (trim (string-reverse p) (string-reverse s))))
	(define (chop p s)
		(string-reverse (trim (string-reverse p) (string-reverse (trim p s)))) )

	;; What are  collect  about again?
	(define (collect p l r)
		(let ( (n (string-length p)) )
			(cond
				((string=? r "") `(,l . "") )
				((prefix? p r) `(,l . ,(right n r)))
				(else (collect p (string-append l (left n r)) (right n r)) )) ))
	(define (split p s)
		(cond
			((string=? s "") `() )
			(else
				(let ( (n (collect p "" s)) )
					(cons (car n) (split p (cdr n))) ) )) )
	)
