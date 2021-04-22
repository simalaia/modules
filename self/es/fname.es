# File naming:
# id-string token key file-ext

# id-string = dt | dt md5  where dt uses underscores
# token = (R | r | I | i | C | c) 0..1 . 0..4
	# Ucase internal file that is private
	# Lcase file that has been shared or is public domain
	# R record                 something created - writing, pictures
	# C Communication          something exchanged - email, IM
	# I Information            something collected articles
	# 0 Personal file
	# 1 Work related file
	# .0 Important documents   backups, finance, email, IM
	# .1 Writing               blog, manuscripts, books, cover letters
	# .2 Design and visuals    art, scientific, figures, seminar
	# .3 Life                  recipes, productivity, vacations
	# .4 Commerce              transactions, returns
# key = keyword
# file-ext = the file extension

. ~/work/projects/modules/self/es/argam.es

fn split-fname {
	let (date = '([a-zA-Z0-9]{7})'
		md5 = '([a-zA-Z0-9]{,32})'
		token = '([RrCcIi][01]\.[0-4])'
		key = '([^.]*)'
		file-ext = '(\..+)') {
		echo $*| sed -E 's/'^$date^$md5^$token^$key^$file-ext^'/\1 \3 \4 \5 \2/' }}

fn add-hash frm to {
	(if {~ $#frm 0} {echo $0 from to}
	{!~ <={access $frm} 0} {echo file not found}
	{let ((m _) = `{md5sum $frm}
			(id tok key ext hsh) = `{split-fname <={if {~ $to ()} {result $frm} {result $to}}}) {
		mv $frm $id$m$tok$key$ext } }) }


fn jn { if {~ `{js $#* \< 3} 1} {result $2} {result $2^$1^<={jn $1 $*(3 ... )} } }

fn fex {
usage = (
'Usage: '^$0^' token extension keys'
'  token = (R | r | I | i | C | c) 0..1 . 0..4'
'  Ucase internal file that is private'
'  Lcase file that has been shared or is public domain'
'  R record                 something created - writing, pictures'
'  C Communication          something exchanged - email, IM'
'  I Information            something collected articles'
'  0 Personal file'
'  1 Work related file'
'  .0 Important documents   backups, finance, email, IM'
'  .1 Writing               blog, manuscripts, books, cover letters'
'  .2 Design and visuals    art, scientific, figures, seminar'
'  .3 Life                  recipes, productivity, vacations'
'  .4 Commerce              transactions, returns' )

	(if {!~ `{js $#* \< 2} 0}
		{echo <={jn \n $usage}; result (usage 0) }
		{let ((tok ext key) = $*) {
			result `dt^$tok^<={jn _ $key}^'.'^$ext } })}

