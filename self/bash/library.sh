
# Library functions.

function book {
	egrep -ni "$1.*;; 02 title" $lib/records|
	sed -E "s/^([0-9]+: )\(\"([^\"]+).+/\1\2/";
}

function fetch {
	n=$(cat| egrep -o "^[0-9]+");
	sed -n "$(($n - 2)) p" $lib/records|
	sed -E "s/.\"([^\"]+).+/\1/"|
	sed -E "s|(.+)|$lib/store/\1|"|
	tr -d "\n";
}
