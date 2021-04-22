# Ease dealing with clipboard

. $modules/es/argam.es

fn clipdiff { let (v = `cat) {cmp -s $clips/current $v} }

fn c {
	let (v = `cat) {
		echo -n $v| clipdiff
		if {!~ $? 0} {
			cp $clips/current $clips/hist/`nt
			echo -n $v > $clips/current } }}

fn p { cat $clips/current }
