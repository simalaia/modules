
# Functions to get the date in base 60 big endian format

fn argam {
	let (n = 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x) {
		echo $n(`{echo $^*^'+1'|j});
	}
}

fn date60 {
	let ((d m y) = `{date +'%d %m %Y'}) {
		(d m y z) = `{argam $d $m `{dc -e '60o '^$y^'p'}}
		echo $y^$z $m $d
	}
}

fn time60 {
	let ((h m s) = `{date +'%H %M %S'}) {
		echo `{argam $h $m $s}
	}
}

fn dt {
	let ((y m d) = `{date60}; (H M S) = `{time60}) {
		echo $y$m$d'_'$H$M$S
	}
}

fn nt { echo -n `dt `{date +'%a'| tr A-Z a-z| sed -E 's/.$//'}| tr -d \n| clip }

# Creates file local links in orgmode format
fn new-time {
	let (t = `{dt| tr -d '\n'}) {
		echo -n '[[here-'$t'][]] <<here-'$t'>> '| clip
	}
}
