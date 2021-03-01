
# Library functions.  I need to extend and complete these.

fn book { egrep -ni $^*^'.*;; 02 title' $lib/records|
	sed -E 's/^([0-9]+: )\("([^"]+).+/\1\2/'
}

fn fetch {
	let (n = `{dc -e `{cat| egrep -o '^[0-9]+'}^' 2-p'}) {
		sed -n $n^' p' $lib/records|
		sed -E 's/."([^"]+).+/\1/'|
		sed -E 's|(.+)|'^$lib/store^'/\1|; s/\s+$//'|
		tr -d '\n'| clip
	}
}
