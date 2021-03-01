
# Link script helper function

fn kl type file opt dot {
	let (PWD = `{pwd -P}; D = '') {
		if (~ $type 'init') {D = $init^'/'^$PWD}
			(~ $type 'etc')  {D = $home}
			(~ $type 'sv')   {D = $SVDIR}
			(~ $type 'xv')   {D = $XVDIR}
			(~ $type 'bin')  {D = $config^'/bin'}
			                 {D = $type} 
		F = $file;
		access $opt $D^'/'^$dot^$F && ln -sf $PWD^'/'^$F $D^'/'^$dot^$F
	}
}
