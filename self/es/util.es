

# I need to port this to es

# rot>1
fn rot { builtin echo $*($#*) $*(`{seq 1 `{echo $#* 1-p| dc}}); }

# Get colours
bold=`{tput bold}
underline=`{tput sgr 0 1}
reset=`{tput sgr0}

purple=`{tput setaf 171}
red=`{tput setaf 1}
green=`{tput setaf 76}
tan=`{tput setaf 3}
blue=`{tput setaf 38}

#
# Print pretty colours
#
fn e_header { echo;echo $bold$purple^'=============='^$*^'=============='^$reset }
fn e_arrow { echo '➜'^$* }
fn e_success { echo $green^'✔'^$*$reset }
fn e_error { echo $red^'✖'^$*$reset }
fn e_warning { echo $tan^'➜'^$*$reset }
fn e_underline { echo $underline$bold$* $reset }
fn e_bold { echo $bold$*$reset }
fn e_note { echo $underline$bold$blue^'[NOTE]: '^$reset$blue$*$reset }


fn confirmation {
 echo $bold $* $reset
 # how do one read input in rc?
 echo;
}

fn confirm_head {
 echo $underline$bold $* $reset
 # read stuff
 echo;
}

fn is_confirmed reply { ~ $reply [Yy] }
fn is_os { {~ `{uname| tr A-Z a-z} $*(1)} }

# This returns the type of commands, it's also a bash builtin
# I will have to see whether rc either has something similar
# or whether I can implement it.
# type [-aftpP] name [name ...]
# With no options, indicate how each name would be interpreted  if
# used as a command name.  If the -t option is used, type prints a
# string which is one of alias,  keyword,  function,  builtin,  or
# file  if  name  is  an  alias,  shell  reserved  word, function,
# builtin, or disk file, respectively.  If the name is not  found,
# then  nothing  is  printed,  and  an exit status of false is re‐
# turned.  If the -p option is used, type either returns the  name
# of  the  disk file that would be executed if name were specified
# as a command name, or nothing if ``type -t name'' would not  re‐
# turn  file.   The  -P option forces a PATH search for each name,
# even if ``type -t name'' would not return file.  If a command is
# hashed, -p and -P print the hashed value, which is not necessar‐
# ily the file that appears first in PATH.  If the  -a  option  is
# used,  type  prints all of the places that contain an executable
# named name.  This includes aliases and functions, if and only if
# the -p option is not also used.  The table of hashed commands is
# not consulted when using -a.  The  -f  option  suppresses  shell
# function lookup, as with the command builtin.  type returns true
# if all of the arguments are found, false if any are not found.

