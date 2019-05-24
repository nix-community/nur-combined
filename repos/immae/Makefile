subrecipes = setup ssh-eldiron info debug dry-run build upload deploy reboot push pull pull-deployment list-generations delete-generations cleanup
${subrecipes}:
	@$(MAKE) --no-print-directory -C nixops/ $@

env:
	./scripts/make-env

env-dry-run:
	./scripts/make-env --dry-run

nix-info:
	NIXOPS_DEPLOYMENT="" ./scripts/nix_infos

nix-info-nixops:
	NIXOPS_DEPLOYMENT="n" ./scripts/nix_infos

nur:
	./scripts/make-nur

shellcheck:
	shellcheck scripts/* nixops/scripts/* modules/private/gitolite/gitolite_ldap_groups.sh modules/private/ssh/ldap_authorized_keys.sh modules/private/pub/restrict

.PHONY: env env-dry-run nix-info nix-info-nixops nur shellcheck
