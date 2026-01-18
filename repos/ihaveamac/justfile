alias mm := merge-master

merge-master:
	git checkout master
	git merge staging
	git checkout staging
	git push origin master

update:
	nix-update --version-regex='makerom-v(.*)' makerom
	nix-update --version-regex='ctrtool-v(.*)' ctrtool
	nix-update --version=branch wfs-tools
	nix-update --version=branch wfs-tools.wfslib
	nix-update --version=branch _3beans
	nix-update --version=branch lnshot
	nix-update --version=branch vanilla
	nix-update retro-aim-server

	nix-shell build-readme.nix
