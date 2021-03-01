
# Used in the dot link scripts to make it a little easier and less error prone to link in dots

function kl {
	PWD=$(pwd -P)
	case $1 in
		init) D=${init}/${PWD##*/};;
		etc)  D=${HOME};;
		sv)   D=${SVDIR};;
		xv)   D=${XVDIR};;
		bin)  D=${config}/bin;;
		*)    D=$1;;
	esac
	F=$2; [ ! $3 "$D/${4}$F" ] && ln -sf "${PWD}/$F" "$D/${4}$F"
}
