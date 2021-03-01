;; -*- mode:scheme -*-
(define-library (lib string)
	(import (chibi) (lib misc) (chibi match) (scheme cxr))
	(export scar scdr scons char string-reverse nil? string-prefix?
		string-left string-right string-trim mirt chop split
	)
	(begin
		;; Due to exessive bugs we're instituting a collection first policy!


		;; Get the first 1String from a string
		;; String → String
		(define (scar s) (substring s 0 1))

		;; Get the rest of a string
		;; String → String
		(define (scdr s) (substring s 1 (string-length s)))

		;; Prepend a string or char to a string
		;; (String | Char) String → String
		(define (scons e s)
			(cond
				((char? e) (string-append (string e) s) )
				((string? e) (string-append e s) )) )

		;; Convert a 1String to a Char
		;; String → Char
		(define (char s)
			(cond
				((char? s) s )
				((and (string? s) (= (string-length s) 1))
					(car (string->list s)) )
				(else (error "string->char hates you") )) )

		(define (string-reverse s) (list->string (reverse (string->list s))) )

		(define (nil? s) (string=? s ""))

		(define (string-prefix? s p)
			(string=? p (substring s 0 (string-length p))) )

		(define (string-left s n) (substring s 0 n))

		(define (string-right s n) (substring s n (string-length s)))

		(define (string-trim s p)
			(if (string-prefix? s p) (string-right (string-length p) s) s))

		(define (mirt p s)
			(string-reverse
				(string-trim (string-reverse p) (string-reverse s))) )

		(define (chop s p)
			(string-reverse
				(string-trim (string-reverse p)
				(string-reverse (string-trim p s)))))

		(define (collect r l p)
			(let ( (n (string-length p)) )
				(cond
					((string=? r "")
						`(,l . "") )
					((string-prefix? r p)
						`(,l . ,(string-right r n)) )
				(else
					(collect (string-right r n) 
						(string-append l (string-left r n)) p) )) ))

		(define (split s p)
			(cond
				((string=? s "") `() )
				(else
					(let ( (n (collect s "" p)) )
						(cons (car n) (split (cdr n) p)) ) )) )
		))
