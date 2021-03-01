
# Functions to make dealing with the clipboard less painful.

 . ${modules}/bash/argam.sh; k=$(cat);

function clipdiff { cmp -s ${clips}/current <(cat); }

function tstclip {
	echo -n "$k"| clipdiff
	if [ $? -ne 0 ]; then echo "$k"; echo "$(unclip)"; fi
}

function clip { . ${modules}/bash/argam.sh; k=$(cat);
	echo -n "$k"| clipdiff
	if [ $? -ne 0 ]; then
		cp ${clips}/current ${clips}/hist/$(nt);
		echo -n "$k" > ${clips}/current; fi
}

function unclip { cat ${clips}/current; }

