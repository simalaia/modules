;; -*- mode:scheme -*-

;; Oleg's standard library, I should figure out how it works

(define-library (lib std)
	(import (chibi) (chibi match)
		(lib macros)
		(scheme cxr) (scheme case-lambda)
		(only (scheme base) parameterize))
	(export gensym nl cerr cout inc inc! dec dec! symbol?? assert
		with-input-from-string with-output-to-string assure id-memv??
		identify-error begin0
		) ;; call-with-input-string call-with-output-string
	(begin
		(define pp #f)
		;;(define gensym gentemp)
		;; (import (srfi 27)) srfi 27
		(define gensym
			(case-lambda
				(() (gensym "") )
				((a) (string->symbol
						(string-append
							"#:"
							(if (equal? a "") a (string-append a "-"))
								(number->string (random-integer 1000000000)))))))


				;; Convenient (and necessary for miniKanren)
		(define (call-with-input-string str proc)
			(proc (open-input-string str)) )
		(define (call-with-output-string proc)
			(let ( (port (open-output-string)) )
				(proc port)
				(get-output-string port) ))
		(define (with-input-from-string str thunk)
			(parameterize ((current-input-port (open-input-string str))) (thunk)) )
		(define (with-output-to-string thunk)
			(let ( (port (open-output-string)) )
				(parameterize ((current-output-port port)) (thunk))
				(get-output-string port) ))

		;; Useful macros
		(define-syntax symbol??
			(syntax-rules ()
				((symbol?? (x . y) kt kf)	kf )	;; a pair, not a symbol
				((symbol?? #(x ...) kt kf) kf )	;; a vector, not a symbol
				((symbol?? maybe-symbol kt kf )
					(let-syntax (
							(test (syntax-rules ()
								((test maybe-symbol t f) t)
								((test x t f) f ))) )
								(test abracadabra kt kf)) )) )

		;; macro-expand-time (memv) function for identifiers
		;; id-memv?? FORM (ID ...) KT KF
		;; FORM is an arbitrary form or datum, ID is an identifier
		;; The macro expands to KT if FORM is an identifier,
		;; which occurs in the list of indentifiers supplied by
		;; the second argument.	All identifiers in that list
		;; must be unique.
		;; Otherwise, id-memv?? expands to KF.
		;; Two identifiers match if both refer to the same
		;; binding occurrence, or or both are defined and have
		;; the same spelling.
		(define-syntax id-memv??
			(syntax-rules ()
				((id-memv?? form (id ...) kt kf)
					(let-syntax
						( (test
							(syntax-rules (id ...)
							((test id _kt _kf) _kt ) ...
							((test otherwise _kt _kf) _kf))) )
							(test form kt kf)) )) )

		;; CPS macros
		;; The macros follow the convention that a continuation
		;; argument has the form (k-head ! args ...) where ! is
		;; a dedicated symbol (placeholder).	When a CPS macro
		;; invokes its continuation, it expands into
		;; k-head value args ...)	To distinguish such calling
		;; conventions we prefix names of such macros with k!
		(define-syntax k!id			;; Identity, useful in CPS
			(syntax-rules ()
				((k!id x) x )) )

		;; k!reverse ACC (FORM ...) K
		;; reverses the second argument, appends it to the
		;; first and passes the result to K
		(define-syntax k!reverse
			(syntax-rules (!)
				((k!reverse acc () (k-head ! . k-args))
					(k-head acc . k-args)
					)
				((k!reverse acc (x . rest) k)
					(k!reverse (x . acc) rest k) )) )

		;; assert the truth of an expression or sequence of
		;; expressions
		;; syntax: assert ?expr ?expr ... [report: ?r-exp ?r-exp ...]
		;; If (and ?expr ?expr ...) evals to anything but #f
		;; the result is the value of that expression.	If it
		;; evals to #f, an error is reported.	The error message
		;; will show the failed expressions as well as the
		;; values of selected variables (or expressions in
		;; general).	The user may explicitly specify the
		;; expression whose values are to be printed upon
		;; assertion failure as ?r-exp that follow the
		;; identifier 'report:'	Typically ?r-exp is either a
		;; variable or a string constant.	If the user specified
		;; no ?r-exp the values of variables that are referenced
		;; in ?expr will be printed upon assertion failure.
		(define-syntax assert
			(syntax-rules ()
				((assert _expr . _others)
					(letrec-syntax
						( (write-report
							(syntax-rules ()
								;; given list of expressions or vars
								;; create a cerr form
								((_ exprs prologue)
									(k!reverse () (cerr . prologue)
									(write-report* ! exprs #\newline))	)) )
						(write-report*
							(syntax-rules ()
								((_ rev-prologue () prefix)
									(mtrace (k!reverse	() (nl . rev-prologue) (k!id !))) )
								((_ rev-prologue (x . rest) prefix)
									(symbol?? x
										(write-report* (x ": " 'x #\newline . rev-prologue)
											rest #\newline)
										(write-report* (x prefix . rev-prologue) rest "") )) ) )
						;; return list of all unique "interesting"
						;; vars in the expr.	Vars that ar certain
						;; to be bound to procedures are not
						;; interesting
						(vars-of
							(syntax-rules (!)
								((_ vars (op . args) (k-head ! . k-args))
									(id-memv?? op (quote let let* letrec let*-values lambda
										cond quasiquote case define do
										assert λ)
									(k-head vars . k-args) ;; won't go inside
									;; ignore head of application
									(vars-of* vars args (k-head ! . k-args))) )
									;; not an application, ignore
								((_ vars non-app (k-head ! . k-args)) (k-head vars . k-args) )))
									(vars-of*
										(syntax-rules (!)
											((_ vars () (k-head ! . k-args)) (k-head vars . k-args) )
											((_ vars (x . rest) k)
												(symbol?? x
													(id-memv?? x vars
														(vars-of* vars rest k)
														(vars-of* (x . vars) rest k))
														(vars-of vars x (vars-of* ! rest k))) )))
									(do-assert
										(syntax-rules (report:)
											((_ () expr)		;; most common case
												(do-assert-c expr) )
											((_ () expr report: . others) ;; another common case
												(do-assert-c expr others) )
											((_ () expr . others) (do-assert (expr and) . others) )
											((_ exprs)
												(k!reverse () exprs (do-assert-c ! others)) )
											((_ exprs x . others) (do-assert (x . exprs) . others) )))
									(do-assert-c
										(syntax-rules ()
											((_ exprs)
												(or exprs
													(begin
														(vars-of
															() exprs
															(write-report
																! ("failed assertion: " 'exprs nl "bindings")))
														(error "assertion failure"))) )
											((_ exprs others)
												(or exprs
													(begin
														(write-report others
															("failed assertion: " 'exprs))
														(error "assertion failure"))) ))) )
								(do-assert () _expr . _others) )) ))

		(define-syntax assure
			(syntax-rules ()
				((assure exp error-msg) (assert exp report: error-msg) )) )

		(define (identify-error msg args . disposition-msgs)
			(let ( (port (console-output-port)) )
				(newline port)
				(display "ERROR" port)
				(display msg port)
				(for-each (lambda (msg) (display msg port))
					(append args disposition-msgs))
				(newline port)) )

		(define console-output-port current-output-port)
		(define nl (string #\newline))
		(define (cout . args)
			(for-each (lambda (x)
				(if (procedure? x) (x) (display x))) args) )
		(define (cerr . args)
			(for-each (lambda (x)
				(if (procedure? x) (x (current-output-port))
					(display x (console-output-port))))
				args) )

		(define-syntax inc!
			(syntax-rules ()
				((inc! x) (set! x (+ 1 x)) )) )
		(define-syntax inc
			(syntax-rules ()
				((inc x) (+ 1 x) )) )

		(define-syntax dec!
			(syntax-rules ()
				((dec! x) (set! x (- x 1)) )) )
		(define-syntax dec
			(syntax-rules ()
				((dec x) (- x 1) )) )

		(define-syntax begin0
			(syntax-rules ()
				((begin0 form form1 ... )
					(let ( (val form) ) form1 ... val) )) )

		(define-syntax push!
			(syntax-rules ()
				((push! item ls)
					(set! ls (cons item ls)) )) )

		(define-syntax string-null?
			(syntax-rules ()
				((string-null? str) (zero? (string-length str)) )) )

		(define (cons* first . rest)
			(let rec ( (x first) (rest rest) )
				(if (pair? rest)
					(cons x (rec (car rest) (cdr rest)))
					x) ))

		;; file-length
		;;(define values list)
		(define-syntax let*-values
			(syntax-rules ()
				((let*-values () . bodies) (begin . bodies) )
				((let*-values (((var) initializer) . rest) . bodies)
					(let ( (var initializer) )		;; single var optimization
						(let*-values rest . bodies)) )
				((let*-values ((vars initializer) . rest) . bodies)
					(call-with-values (lambda () initializer) ;; most generic case
						(lambda vars (let*-values rest . bodies))) )) )

		(define-syntax lookup-def
			(syntax-rules (warn:)
				((lookup-def key alist)
					(let ((nkey key) (nalist alist)) ;; eval them only once
						(let ((res (assq nkey nalist)))
							(if res
								(let ((res (cdr res)))
									(cond
										((not (pair? res)) res)
										((null? (cdr res)) (car res))
										(else res)))
											(error "Failed to find " nkey " in " nalist)))) )
				((lookup-def key alist default-exp)
					(let ((res (assq key alist)))
						(if res
							(let ((res (cdr res)))
								(cond
									((not (pair? res)) res)
									((null? (cdr res)) (car res))
									(else res)))
							default-exp)) )
				((lookup-def key alist warn: default-exp)
					(let ((nkey key) (nalist alist))	;; eval them only once
						(let ((res (assq nkey nalist)))
							(if res
								(let ((res (cdr res)))
									(cond
										((not (pair? res)) res)
										((null? (cdr res)) (car res))
										(else res)))
								(begin
									(cerr "Failed to find " nkey " in " nalist #\newline)
									defaul-exp)))) )) )

		)
	)
