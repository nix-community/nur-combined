.PHONY: link update

update:
	@ http POST https://nur-update.herokuapp.com/update repo==yurrriq


link:
	@ mkdir -p ~/.config/nurpkgs
	@ stow -Rvt ~/.config/nurpkgs .


.PHONY: $(wildcard *.json)


all: $(wildcard *.json)


nix/%.json: branch=$(shell <$@ jq -r .branch)
nix/%.json: owner=$(shell <$@ jq -r .owner)
nix/%.json: repo=$(shell <$@ jq -r .repo)
nix/%.json: rev=$(shell http --session=github "https://api.github.com/repos/${owner}/${repo}/git/refs/heads/${branch}" Accept:application/vnd.github.v3+json | jq -r '.object.sha')
nix/%.json: sha256=$(shell nix-prefetch-url --unpack "https://github.com/${owner}/${repo}/tarball/${rev}")
nix/%.json: COMMIT_MSG_FILE=.git/COMMIT_EDITMSG
nix/%.json:
	@ printf "$(patsubst %.json,%,$(notdir $@)): %s -> " \
		$$(jq -r '.rev[:8]' "$@") \
		>${COMMIT_MSG_FILE}
	@ jq '.rev = "${rev}" | .sha256 = "${sha256}"' "$@" | sponge "$@"
	@ jq -r '.rev[:8]' "$@" >>${COMMIT_MSG_FILE}
	@ git add $$(realpath "$@")
	@ git commit -F ${COMMIT_MSG_FILE}
