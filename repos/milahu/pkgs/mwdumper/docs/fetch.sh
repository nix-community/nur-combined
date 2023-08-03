#! /bin/sh

# grep: remove the translations block
# grep: remove the "not active" block

# not working: images are not fetched
# wget -p https://www.mediawiki.org/wiki/Manual:MWDumper?action=render -O mwdumper.html

curl -s https://www.mediawiki.org/wiki/Manual:MWDumper?action=render |
grep -m1 -A9999999 -F '<style data-mw-deduplicate' |
grep -v -F 'Beware that MWDumper has not been actively maintained since the mid-2000s' |
grep -v -F 'This page is obsolete. It is being retained for archival purposes.' |
cat >mwdumper.html

pandoc mwdumper.html -f html -t man -o mwdumper.man
