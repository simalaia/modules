
# Delimited values conversions

fn tsv2dv { cat| tr \t \037| tr \n \036 }
fn csv2dv { cat| tr  , \037| tr \n \036 }
fn dv2dsp { cat| sed -E 's/\x1F/\x1F\t/; s/\x1E/\x1E\n/g' }
