.PHONY: link niv-update update


niv-update: package ?= nixpkgs
niv-update: sources := nix/sources.json
niv-update: rev = $(shell jq -r '.["${package}"].rev[:8]' ${sources})
niv-update: COMMIT_MSG_FILE = ../../../../.git/COMMIT_EDITMSG
niv-update:
	@ niv update ${package}
	@ git add ${sources}
	@ jq '"${package}: ${rev} -> \(.["${package}"].rev[:8])"' \
	${sources} | xargs git commit -m


update:
	@ http POST https://nur-update.herokuapp.com/update repo==yurrriq


link:
	@ mkdir -p ~/.config/nurpkgs
	@ stow -Rvt ~/.config/nurpkgs .
