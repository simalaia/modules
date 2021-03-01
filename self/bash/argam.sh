
# Functions to get dates in base 60 format, mostly for use as unique values

# Convert number to base sixty
function argam {
  read -r -a conv <<< "0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x"
  echo ${conv[10#$1]};
}

# Today
function date60 {
  read -r -a today <<< $(date +'%d %m %Y')
  read -r -a year <<< $(echo "obase=60; ${today[2]}"| bc)
  echo -n $(argam ${today[0]})$(argam ${today[1]})
  echo $(argam ${year[0]})$(argam ${year[1]});
}

# Now
function time60 {
  read -r -a now <<< $(date +'%H %M %S')
  echo $(argam ${now[0]})$(argam ${now[1]})$(argam ${now[2]})
}

# The old date time format I use
function dt {
  echo $(date60)-$(time60);
}

# The new and better format
function undate {
  read -r -a today <<< $(date +'%Y %m %d')
  read -r -a year <<< $(echo "obase=60; ${today[0]}"| bc)
  echo -n $(argam ${year[0]})$(argam ${year[1]});
  echo -n $(argam ${today[1]})$(argam ${today[2]})
}
function nt {
  echo $(undate)-$(time60);
}

# Formerly used to create file local links.  Now it is out of date and incorrect
function new_time {
  t=$(dt| tr -d "\n")
  echo -n "[[here-${t}][]] <<here-${t}>> "| pbcopy
}
