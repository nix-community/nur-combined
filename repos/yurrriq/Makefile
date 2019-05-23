.PHONY: link update

update:
	@ http POST https://nur-update.herokuapp.com/update repo==yurrriq


link:
	@ mkdir -p ~/.config/nurpkgs
	@ stow -Rvt ~/.config/nurpkgs .


.PHONY: $(wildcard *.json)


all: $(wildcard *.json)


%.json: branch=$(shell <$@ jq -r .branch)
%.json: owner=$(shell <$@ jq -r .owner)
%.json: repo=$(shell <$@ jq -r .repo)
%.json: rev=$(shell http --session=github "https://api.github.com/repos/${owner}/${repo}/git/refs/heads/${branch}" Accept:application/vnd.github.v3+json | jq -r '.object.sha')
%.json: sha256=$(shell nix-prefetch-url --unpack "https://github.com/${owner}/${repo}/tarball/${rev}")
%.json: COMMIT_MSG_FILE=.git/COMMIT_EDITMSG
nixpkgs.json:
	@ printf "$(patsubst %.json,%,$(notdir $@)): %s -> " \
		$$(jq -r '.rev[:8]' "$@") \
		>${COMMIT_MSG_FILE}
	@ jq '.rev = "${rev}" | .sha256 = "${sha256}"' "$@" | sponge "$@"
	@ jq -r '.rev[:8]' "$@" >>${COMMIT_MSG_FILE}
	@ git add $$(realpath "$@")
	@ git commit -F ${COMMIT_MSG_FILE}
