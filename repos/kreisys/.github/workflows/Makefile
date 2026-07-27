ci.yml: ci.nix
	nix-instantiate --eval --json --strict $? | jq . > $@
