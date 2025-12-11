#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
# vim: set filetype=python :
"""
generate files for any of 16 DTMF tones 0-9, #, *, A, B, C, D,
as per <https://en.wikipedia.org/wiki/DTMF_signaling#Keypad>
"""

import argparse
import logging

logger = logging.getLogger(__name__)

def main():
    logging.basicConfig()
    logging.getLogger().setLevel(logging.INFO)

    parser = argparse.ArgumentParser(usage=__doc__)
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument("name", type=str, choices=['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '#', '*', 'A', 'B', 'C', 'D'])
    parser.add_argument("--out", type=str)

    args = parser.parse_args()

    if args.verbose:
          logging.getLogger().setLevel(logging.DEBUG)

    logger.info("generating tone for '%s' -> '%s'", args.name, args.out)


if __name__ == '__main__':
    main()
