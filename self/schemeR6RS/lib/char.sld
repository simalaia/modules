;; -*- mode:scheme -*-
;; Less annoying character whatsits
(library (lib char)
	(export char->string char-control? char-lower->ctrl)
	(import (rnrs))

	;;  Probably the nicest function here
	(define (char->string c) (list->string `(,c)) )

	;; I don't remember why I wrote these...
	(define (char-control? c)
		(if (char? c) (not (< 31 (char->integer c) 127))
			(error 'meh "char-control? hates you")) )
	(define (char-lower->ctrl c)
		(if (and (char? c) (char-lower-case? c))
			(integer->char (- (char->integer c) 96))
			(error 'meh "ctrl-key hates you")) )

  )
