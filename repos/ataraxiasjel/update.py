#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Minimal

import argparse
import os
import subprocess
import sys
from subprocess import PIPE


def main(args):
    path = os.getcwd()

    if args.nixpkgs:
        nixpkgs = args.nixpkgs
    else:
        nixpkgs = subprocess.check_output(['nix-instantiate', '--find-file', 'nixpkgs'], text=True).strip()

    update_nix = os.path.join(nixpkgs, 'maintainers/scripts/update.nix')

    nix_args = [update_nix]
    nix_args += ['--arg', 'include-overlays', f'[(import {path}/overlay.nix)]']

    if args.maintainer:
        nix_args += ['--argstr', 'maintainer', args.maintainer]
    elif args.package:
        nix_args += ['--argstr', 'package', args.package]
    elif args.attr_path:
        nix_args += ['--argstr', 'path', args.attr_path]
    elif args.predicate:
        nix_args += ['--arg', 'predicate', args.predicate]

    if args.commit:
        nix_args += ['--argstr', 'commit', 'true']

    nix_shell = ['nix-shell'] + nix_args

    with subprocess.Popen(nix_shell, stdin=PIPE) as proc:
        proc.communicate(input=b'\n')
        return proc.returncode

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Update package source')
    req = parser.add_mutually_exclusive_group(required=True)
    req.add_argument('-m', '--maintainer', dest='maintainer', help='Update all packages with this maintainer')
    req.add_argument('-P', '--package', dest='package', help='Package to update')
    req.add_argument('-a', '--attr_path', dest='attr_path', help='Attribute path of package to update')
    req.add_argument('-p', '--predicate', dest='predicate', help='Update all packages matching given predicate')
    parser.add_argument('-c', '--commit', help='Commit the changes', action='store_true')
    parser.add_argument('-n', '--nixpkgs', dest='nixpkgs', help='Override the nixpkgs flake input with this path', nargs='?')

    args = parser.parse_args()

    sys.exit(main(args))
