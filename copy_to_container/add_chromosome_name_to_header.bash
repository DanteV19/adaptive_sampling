#!/bin/bash

# Add the chromosome symbol (either number or XY) at the start of the header when indicated in the header,  so the resulting format can be used by BOSS-RUNS
# Otherwise, add U for unplaced when the sequence does not have any specific chromosome
sed -E '/chromosome/ s/(>)([[:alnum:]_.-]*\s*[[:alnum:]_.-]*\s*[[:alnum:]_.-]*\s*[[:alnum:]_.-]*\s*)([[:digit:]XY]*)/>chr\3 \2\3/g' $1 | sed -E '/unplaced/ s/>/>chrU /g' | sed -E '/mitochondrion/ s/>/>chrM /g'

