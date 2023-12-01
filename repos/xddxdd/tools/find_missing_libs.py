#!/usr/bin/env python
import os
import re
import sys

if len(sys.argv) < 2:
    print('Usage: {} log.txt'.format(sys.argv[0]))
    exit(1)

libraries_ok = set()
libraries_fail = set()

for filename in sys.argv[1:]:
    with open(filename) as f:
        # data = f.readlines()
        for line in f:
            result = re.match(r'.*\"(.*\.so.*)\"(.*)', line)
            if result is None:
                continue
            file = result.group(1)
            basename = os.path.basename(file)
            found = re.match(r'.*= -[0-9]+.*', result.group(2)) is None

            if found:
                libraries_ok.add(basename)
            else:
                libraries_fail.add(basename)

for lib in libraries_fail - libraries_ok:
    print(lib)
