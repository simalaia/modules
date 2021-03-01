
;; I need to port this to Chibi, it'll make dealing with my website much less painful
(define-module (lib html)
	#:use-module (sxml simple)
	#:use-module (srfi srfi-26)
	#:use-module (ice-9 match)
	#:use-module (ice-9 format)
	#:use-module (ice-9 hash-table)
	#:export (sxml->html))

(define %void-elements
	'(area base br col command embed hr img input
	keygen link meta param source track wbr))

(define (void-element? tag)
	"Return #t if TAG is a void element."
	(pair? (memq tag %void-elements)))

(define %escape-chars
	(alist->hash-table
		'((#\" . "quot"    ) (#\& . "amp") (#\' . "apos") (#\< . "lt")
    (#\> . "gt"      ) (#\¡ . "iexcl") (#\¢ . "cent") (#\£ . "pound")
    (#\¤ . "curren"  ) (#\¥ . "yen") (#\¦ . "brvbar") (#\§ . "sect")
    (#\¨ . "uml"     ) (#\© . "copy") (#\ª . "ordf") (#\« . "laquo")
    (#\¬ . "not"     ) (#\® . "reg") (#\¯ . "macr") (#\° . "deg")
    (#\± . "plusmn"  ) (#\² . "sup2") (#\³ . "sup3") (#\´ . "acute")
    (#\µ . "micro"   ) (#\¶ . "para") (#\· . "middot") (#\¸ . "cedil")
    (#\¹ . "sup1"    ) (#\º . "ordm") (#\» . "raquo") (#\¼ . "frac14")
    (#\½ . "frac12"  ) (#\¾ . "frac34") (#\¿ . "iquest") (#\À . "Agrave")
    (#\Á . "Aacute"  ) (#\Â . "Acirc") (#\Ã . "Atilde") (#\Ä . "Auml")
    (#\Å . "Aring"   ) (#\Æ . "AElig") (#\Ç . "Ccedil") (#\È . "Egrave")
    (#\É . "Eacute"  ) (#\Ê . "Ecirc") (#\Ë . "Euml") (#\Ì . "Igrave")
    (#\Í . "Iacute"  ) (#\Î . "Icirc") (#\Ï . "Iuml") (#\Ð . "ETH")
    (#\Ñ . "Ntilde"  ) (#\Ò . "Ograve") (#\Ó . "Oacute") (#\Ô . "Ocirc")
    (#\Õ . "Otilde"  ) (#\Ö . "Ouml") (#\× . "times") (#\Ø . "Oslash")
    (#\Ù . "Ugrave"  ) (#\Ú . "Uacute") (#\Û . "Ucirc") (#\Ü . "Uuml")
    (#\Ý . "Yacute"  ) (#\Þ . "THORN") (#\ß . "szlig") (#\à . "agrave")
    (#\á . "aacute"  ) (#\â . "acirc") (#\ã . "atilde") (#\ä . "auml")
    (#\å . "aring"   ) (#\æ . "aelig") (#\ç . "ccedil") (#\è . "egrave")
    (#\é . "eacute"  ) (#\ê . "ecirc") (#\ë . "euml") (#\ì . "igrave")
    (#\í . "iacute"  ) (#\î . "icirc") (#\ï . "iuml") (#\ð . "eth")
    (#\ñ . "ntilde"  ) (#\ò . "ograve") (#\ó . "oacute") (#\ô . "ocirc")
    (#\õ . "otilde"  ) (#\ö . "ouml") (#\÷ . "divide") (#\ø . "oslash")
    (#\ù . "ugrave"  ) (#\ú . "uacute") (#\û . "ucirc") (#\ü . "uuml")
    (#\ý . "yacute"  ) (#\þ . "thorn") (#\ÿ . "yuml") (#\Œ . "OElig")
    (#\œ . "oelig"   ) (#\Š . "Scaron") (#\š . "scaron") (#\Ÿ . "Yuml")
    (#\ƒ . "fnof"    ) (#\ˆ . "circ") (#\˜ . "tilde") (#\Α . "Alpha")
    (#\Β . "Beta"    ) (#\Γ . "Gamma") (#\Δ . "Delta") (#\Ε . "Epsilon")
    (#\Ζ . "Zeta"    ) (#\Η . "Eta") (#\Θ . "Theta") (#\Ι . "Iota")
    (#\Κ . "Kappa"   ) (#\Λ . "Lambda") (#\Μ . "Mu") (#\Ν . "Nu")
    (#\Ξ . "Xi"      ) (#\Ο . "Omicron") (#\Π . "Pi") (#\Ρ . "Rho")
    (#\Σ . "Sigma"   ) (#\Τ . "Tau") (#\Υ . "Upsilon") (#\Φ . "Phi")
    (#\Χ . "Chi"     ) (#\Ψ . "Psi") (#\Ω . "Omega") (#\α . "alpha")
    (#\β . "beta"    ) (#\γ . "gamma") (#\δ . "delta") (#\ε . "epsilon")
    (#\ζ . "zeta"    ) (#\η . "eta") (#\θ . "theta") (#\ι . "iota")
    (#\κ . "kappa"   ) (#\λ . "lambda") (#\μ . "mu") (#\ν . "nu")
    (#\ξ . "xi"      ) (#\ο . "omicron") (#\π . "pi") (#\ρ . "rho")
    (#\ς . "sigmaf"  ) (#\σ . "sigma") (#\τ . "tau") (#\υ . "upsilon")
    (#\φ . "phi"     ) (#\χ . "chi") (#\ψ . "psi") (#\ω . "omega")
    (#\ϑ . "thetasym") (#\ϒ . "upsih") (#\ϖ . "piv") (#\  . "ensp")
    (#\  . "emsp"    ) (#\  . "thinsp") (#\– . "ndash") (#\— . "mdash")
    (#\‘ . "lsquo"   ) (#\’ . "rsquo") (#\‚ . "sbquo") (#\“ . "ldquo")
    (#\” . "rdquo"   ) (#\„ . "bdquo") (#\† . "dagger") (#\‡ . "Dagger")
    (#\• . "bull"    ) (#\… . "hellip") (#\‰ . "permil") (#\′ . "prime")
    (#\″ . "Prime"   ) (#\‹ . "lsaquo") (#\› . "rsaquo") (#\‾ . "oline")
    (#\⁄ . "frasl"   ) (#\€ . "euro") (#\ℑ . "image") (#\℘ . "weierp")
    (#\ℜ . "real"    ) (#\™ . "trade") (#\ℵ . "alefsym") (#\← . "larr")
    (#\↑ . "uarr"    ) (#\→ . "rarr") (#\↓ . "darr") (#\↔ . "harr")
    (#\↵ . "crarr"   ) (#\⇐ . "lArr") (#\⇑ . "uArr") (#\⇒ . "rArr")
    (#\⇓ . "dArr"    ) (#\⇔ . "hArr") (#\∀ . "forall") (#\∂ . "part")
    (#\∃ . "exist"   ) (#\∅ . "empty") (#\∇ . "nabla") (#\∈ . "isin")
    (#\∉ . "notin"   ) (#\∋ . "ni") (#\∏ . "prod") (#\∑ . "sum")
    (#\− . "minus"   ) (#\∗ . "lowast") (#\√ . "radic") (#\∝ . "prop")
    (#\∞ . "infin"   ) (#\∠ . "ang") (#\∧ . "and") (#\∨ . "or")
    (#\∩ . "cap"     ) (#\∪ . "cup") (#\∫ . "int") (#\∴ . "there4")
    (#\∼ . "sim"     ) (#\≅ . "cong") (#\≈ . "asymp") (#\≠ . "ne")
    (#\≡ . "equiv"   ) (#\≤ . "le") (#\≥ . "ge") (#\⊂ . "sub")
    (#\⊃ . "sup"     ) (#\⊄ . "nsub") (#\⊆ . "sube") (#\⊇ . "supe")
    (#\⊕ . "oplus"   ) (#\⊗ . "otimes") (#\⊥ . "perp") (#\⋅ . "sdot")
    (#\⋮ . "vellip"  ) (#\⌈ . "lceil") (#\⌉ . "rceil") (#\⌊ . "lfloor")
    (#\⌋ . "rfloor"  ) (#\〈 . "lang") (#\〉 . "rang") (#\◊ . "loz")
    (#\♠ . "spades"  ) (#\♣ . "clubs") (#\♥ . "hearts") (#\♦ . "diams"))))

(define (string->escaped-html s port)
	"Write the HTML escaped form of S to PORT."
	(define (escape c)
		(let ((escaped (hash-ref %escape-chars c)))
			(if escaped
				(format port "&~a;" escaped)
				(display c port))))
	(string-for-each escape s))

(define (object->escaped-html obj port)
	"Write the HTML escaped form of OBJ to PORT."
	(string->escaped-html
		(call-with-output-string (cut display obj <>))
		port))

(define (attribute-value->html value port)
	"Write the HTML escaped form of VALUE to PORT."
	(if (string? value)
		(string->escaped-html value port)
		(object->escaped-html value port)))

(define (attribute->html attr value port)
	"Write ATTR and VALUE to PORT."
	(format port "~a=\"" attr)
	(attribute-value->html value port)
	(display #\" port))

(define (element->html tag attrs body port)
	"Write the HTML TAG to PORT, where TAG has the attributes in the list ATTRS and the child nodes in BODY."
	(format port "<~a" tag)
	(for-each (match-lambda
			((attr value)
				(display #\space port)
				(attribute->html attr value port)))
		attrs)
	(if (and (null? body) (void-element? tag))
		(display " />" port)
		(begin
			(display #\> port)
			(for-each (cut sxml->html <> port) body)
			(format port "</~a>" tag))))

(define (doctype->html doctype port)
	(format port "<!DOCTYPE ~a>" doctype))

(define* (sxml->html tree #:optional (port (current-output-port)))
	"Write the serialized HTML form of TREE to PORT."
	(match tree
		(() *unspecified*)
		(('doctype type) (doctype->html type port))
		(('raw html) (display html port))
		(((? symbol? tag) ('@ attrs ...) body ...)
			(element->html tag '() body port))
		((nodes ...) (for-each (cut sxml->html <> port) nodes))
		((? string? text) (string->escaped-html text port))
		(obj (object->escaped-html obj port))))
