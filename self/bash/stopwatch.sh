
function stopwatch() {
 local BEGIN=$(date +%s)
 echo Starting Stopwatch...

 while true; do
  local NOW=$(date +%s)
  local DIFF=$(($NOW - $BEGIN))
  local MINS=$(($DIFF / 60))
  local SECS=$(($DIFF % 60))
  local HOURS=$(($DIFF / 3600))
  local DAYS=$(($DIFF / 86400))
 
  printf "\r%3d Days, %02d:%02d:%02d" $DAYS $HOURS $MINS $SECS
		read -t 1 -s
		if [ $? -eq 0 ]; then
			echo
			BEGIN=$(date +%s)
		fi
  done
}
