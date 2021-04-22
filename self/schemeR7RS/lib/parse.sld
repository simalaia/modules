;; -*- mode:scheme -*-

;; Attempts at implementing the clojure transducer idea

(define-library (lib parse)
	(import (chibi) ;; (chibi match)
		(lib misc)
		;;(scheme case-lambda) (only (scheme base) define-record-type)
		;;(scheme cxr) (only (scheme base) symbol=? when unless)
		)
	(export skip-const read-const oneof range
		skip skip-until skip-while
		reads read-until read-while
		)
	(begin
		(define (sar s) (substring s 0 1) )
		(define (sdr s) (substring s 1 (string-length s)) )
		(define (char s)
			(if (and (string? s) (= (string-length s) 1))
				(car (string->list s))
				s) )

		(define (explode s)
			(cond
				((string=? s "") '() )
				(#t (cons (char (sar s)) (explode (sdr s))) )) )
		(define (implode s) (apply string-append (map string s)))

		(define (skip-const s)
			(let ( (s (explode s)) )
				(lambda (p)
					(let lop ( (s s) )
						(cond
							((or (null? s) (eof-object? (peek-char p))) '() )
							((char=? (car s) (char (peek-char p)))
								(read-char p) (lop (cdr s)) )) )) ))

		(define (read-const s)
			(let ( (s (explode s)) )
				(lambda (p)
					(let lop ( (s s) )
						(cond
							((or (null? s) (eof-object? (peek-char p))) '() )
							((char=? (car s) (char (peek-char p)))
								(let ( (c (read-char p)) ) (cons c (lop (cdr s))) ) )
							(#t '() )) )) ))

		(define (skip ? p)
			(cond
				((or (eof-object? (peek-char p)) (not (? (peek-char p)))) '() )
				(#t (read-char p) (skip ? p) )) )

		(define (reads ? p)
			(cond
				((or (eof-object? (peek-char p)) (not (? (peek-char p)))) '() )
				(#t (let ( (c (read-char p)) ) (cons c (reads ? p)) ) )) )

		(define (oneof s)
			(let ( (s (map char (string->list s))) )
				(lambda (x)
					(did? (member (char x) s))) ))

		(define (range s)
			(define (nextchar r) (integer->char (+ 1 (char->integer (char r)))) )
			(let ( (s
						(let lop ( (b (sar s)) (e (sdr s)) )
							(cond
								((char=? (char b) (char e)) `(,(char e)) )
								(#t (cons (char b) (lop (string (nextchar b)) e)) )) )) )
				(lambda (x) (did? (member (char x) s))) ))

		(define (skip-until ?) (lambda (p) (skip (lambda (x) (not (? x)) ) p) ))
		(define (skip-while ?) (lambda (p) (skip ? p) ))

		(define (read-until ?) (lambda (p) (reads (lambda (x) (not (? x)) ) p) ))
		(define (read-while ?) (lambda (p) (reads ? p) ))
		)
	)


