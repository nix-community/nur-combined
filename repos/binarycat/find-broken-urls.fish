#!/usr/bin/env fish

# must be run as a trusted user in order to disable sandbox (needed for network access)

set -l abc a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 _ -

set -g prefix_list $argv

if test (count $prefix_list) = 0
	set prefix_list $abc$abc
end

# carteasean product
for pre in $prefix_list
	echo >/proc/self/fd/2 prefix: $pre
	# given a certian prefix to check, check that packages with that prefix don't have any proken urls
	# this piecewise method is needed because otherwise nix uses too much memory
	# -j 1 to make our log output linear
	nix-build --keep-going -j 1 --show-trace --no-sandbox -E '(import ./. {}).lib.testers.checkMetaUrlsPkgPrefix "'$pre'"' 2>/tmp/url-log-err >/tmp/url-log-out

	# for every derivation that failed to build, we find the previous
	# log entry that says a url is being fetched
	tac /tmp/url-log-err | awk '
BEGIN { FS = "\t" }
/error: builder for/ { r = 1 };
/^checking if url exists:/ {
  if(r == 1) { print }; r = 0
}
' | sed 's/^checking if url exists: //'
end


