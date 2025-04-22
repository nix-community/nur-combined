#!/usr/bin/env bash

# the expected freetz-ng/tools/ is built by this docker image
# this takes a few hours...
# https://github.com/pfichtner/pfichtner-freetz

cat >/dev/null <<'EOF'
  docker run --rm -it -v $PWD/freetz-workspace:/workspace pfichtner/freetz
  git clone --depth=1 https://github.com/Freetz-NG/freetz-ng
  cd freetz-ng
  make menuconfig
  make
EOF

nix-build . -A freetz-tools
( cd ~/src/freetz/freetz-ng && find tools | sort | sort > freetz-tools-expected.txt )
( cd result/opt/freetz/ && find tools ) | sort >freetz-tools-actual.txt
diff -u freetz-tools-actual.txt ~/src/freetz/freetz-ng/freetz-tools-expected.txt | less

exit

todo find missing packages

nix-locate --top-level --whole-name --at-root /bin/blkid

nix-locate --top-level --whole-name --at-root --regex '/bin/(bomtool|ccmake)'
