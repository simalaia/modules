
# I need a solution for a timed-read, my attempt failed to do so.
fn stopwatch {
	let (fn-now = @ {date +%s}; begin =) {
		begin = `now
		echo starting stopwatch

		forever {
			let (cur =; diff =; mins =; secs =; hours =; days =) {
				cur  = `now;
				diff = `{js $cur - $begin};
				(hours mins secs) = `{js 24 60 60 \#: $diff}
				days = `{js \<\. $diff % 86400}

				printf '\r%3d days, %02d:%02d:%02d' $days $hours $mins $secs
				if {~ <={sleep 1} 0} {echo; begin = `now} }} }}
