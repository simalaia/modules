
# Functions to get the date in base 60 big endian format

fn argam {
	let (n = 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x) {
		echo $n(`{js $^* +1}); } }

fn date60 {
	let ((y m d) = `{date +'%Y %m %d'}) {
		(y z m d) = `{argam `{dc -e '60o '^$y^'p'} `{js $m $d -1} }
		echo $y^$z $m $d| tr -d ' ' } }

fn time60 { argam `{date +'%H %M %S'}| tr -d ' ' }

fn dt { echo `date60^`time60 }

fn nt { echo -n `dt `{date +'%a'| tr A-Z a-z| sed -E 's/.$//'}| tr -d \n| clip }

# Creates file local links in orgmode format
fn new-time {
	let (t = `{dt| tr -d '\n'}) {
		echo -n '[[here-'$t'][]] <<here-'$t'>> '| clip
	}
}
