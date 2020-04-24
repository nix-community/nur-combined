subrecipes = setup nix-info
subrecipes += nixops ssh-eldiron ssh-backup-2 ssh-monitoring-1
subrecipes += info debug dry-run build upload deploy deploy-reboot reboot
subrecipes += list-generations delete-generations cleanup
subrecipes += pull pull_environment pull_deployment deployment_is_set push push_deployment push_environment
${subrecipes}:
	@$(MAKE) --no-print-directory -C nixops/ $@
.PHONY: ${subrecipes}

nur:
	./scripts/make-nur
	curl -o /dev/null -XPOST "https://nur-update.herokuapp.com/update?repo=immae"

shellcheck:
	shellcheck scripts/* nixops/scripts/* modules/private/gitolite/gitolite_ldap_groups.sh modules/private/ssh/ldap_authorized_keys.sh modules/private/pub/restrict

.PHONY: nur shellcheck
