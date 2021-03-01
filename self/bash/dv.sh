
# Make dealing with delimited files less shitty

function tsv2dv { cat| tr "\t" "\037"| tr "\n" "\036"; }
function csv2dv { cat| tr ","  "\037"| tr "\n" "\036"; }
function dv2tsv { cat| tr "\037" "\t"| tr "\036" "\n"; }
