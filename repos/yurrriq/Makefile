.PHONY: link update

update:
	@ http POST https://nur-update.herokuapp.com/update repo==yurrriq


link:
	@ mkdir -p ~/.config/nurpkgs
	@ stow -Rvt ~/.config/nurpkgs .
