#!/usr/bin/env sh
# hewwo.sh
tr rlRL wwWW | \
    sed -r -e 's/([nN])([aeiou])/\1y\2/g' -e 's/(N)([AEIOU])/\1Y\2/g' -e 's/ove/uv/g' |
    perl -pe 's/\!+/" ".("(・`ω´・)",";;w;;","owo","UwU",">w<","^w^")[rand(6)]." "/eg'
