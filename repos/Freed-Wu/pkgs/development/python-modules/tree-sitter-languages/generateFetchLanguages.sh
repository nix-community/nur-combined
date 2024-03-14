#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git -p jq
#shellcheck shell=bash disable=SC2016

declare -A list=(
	[tree - sitter - erlang]=WhatsApp
	[tree - sitter - lua]=Azganoth
	[tree - sitter - elisp]=Wilfred
	[tree - sitter - fixed - form - fortran]=ZedThree
	[tree - sitter - make]=alemuller
	[tree - sitter - dockerfile]=camdencheek
	[tree - sitter - go - mod]=camdencheek
	[tree - sitter - sqlite]=dhcmrlchtdj
	[tree - sitter - elixir]=elixir-lang
	[tree - sitter - elm]=elm-tooling
	[tree - sitter - kotlin]=fwcd
	[tree - sitter - perl]=ganezdragon
	[tree - sitter - markdown]=ikatyang
	[tree - sitter - yaml]=ikatyang
	[tree - sitter - objc]=jiyee
	[tree - sitter - sql]=m-novikov
	[tree - sitter - hcl]=MichaHoffmann
	[tree - sitter - r]=r-lib
	[tree - sitter - dot]=rydesun
	[tree - sitter - hack]=slackhq
	[tree - sitter - fortran]=stadelmanma
	[tree - sitter - rst]=stsewd
	[tree - sitter - commonlisp]=theHamsta
	[tree - sitter - bash]=tree-sitter
	[tree - sitter - c]=tree-sitter
	[tree - sitter - c - sharp]=tree-sitter
	[tree - sitter - cpp]=tree-sitter
	[tree - sitter - css]=tree-sitter
	[tree - sitter - embedded - template]=tree-sitter
	[tree - sitter - go]=tree-sitter
	[tree - sitter - haskell]=tree-sitter
	[tree - sitter - html]=tree-sitter
	[tree - sitter - java]=tree-sitter
	[tree - sitter - javascript]=tree-sitter
	[tree - sitter - jsdoc]=tree-sitter
	[tree - sitter - json]=tree-sitter
	[tree - sitter - julia]=tree-sitter
	[tree - sitter - ocaml]=tree-sitter
	[tree - sitter - php]=tree-sitter
	[tree - sitter - python]=tree-sitter
	[tree - sitter - ql]=tree-sitter
	[tree - sitter - regex]=tree-sitter
	[tree - sitter - ruby]=tree-sitter
	[tree - sitter - rust]=tree-sitter
	[tree - sitter - scala]=tree-sitter
	[tree - sitter - toml]=tree-sitter
	[tree - sitter - tsq]=tree-sitter
	[tree - sitter - typescript]=tree-sitter
)

echo "# Generated using generateFetchLanguages.sh"
echo "fetchFromGitHub:"
echo \'\'
echo "mkdir -p vendor"
for repo in "${!list[@]}"; do
	owner=${list[$repo]}
	echo 'ln -sv ${fetchFromGitHub {'
	echo "  owner = \"$owner\";"
	echo "  repo = \"$repo\";"
	dir=
	if [[ $repo == *-php ]]; then
		dir=/php
	fi
	nix-prefetch-git --quiet "https://github.com/$owner/$repo" |
		jq '{ rev: .rev, sha256: .sha256 }' |
		jq -r 'to_entries | map("  \(.key) = \"\(.value)\";") | .[]'
	echo "}}$dir vendor/$repo"
done
echo 'python build.py'
echo \'\'
