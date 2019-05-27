subrecipes = setup
subrecipes += nixops ssh-eldiron info debug dry-run build upload deploy deploy-reboot reboot
subrecipes += list-generations delete-generations cleanup
subrecipes += pull pull_environment pull_deployment deployment_is_set push push_deployment push_environment
${subrecipes}:
	@$(MAKE) --no-print-directory -C nixops/ $@
.PHONY: ${subrecipes}

# This will automatically upgrade to latest version at each build
nixpkgs ?= https://nixos.org/channels/nixos-19.03/nixexprs.tar.xz
NIX_PATH = nixpkgs=${nixpkgs}:nixpkgsNext=${nixpkgs}:nixpkgsPrevious=${nixpkgs}

nix-path:
	@echo "export NIX_PATH=$(NIX_PATH)"

env:
	./scripts/make-env

env-dry-run:
	./scripts/make-env --dry-run

nix-info:
	@version=$$(nix eval --raw nixpkgs.lib.version) && \
	  mainversion=$$(echo $$version | cut -d"." -f -2) && \
	  echo "https://releases.nixos.org/nixos/$$mainversion/nixos-$$version/nixexprs.tar.xz" && \
	  nix eval --raw nixpkgs.bc.meta.position | cut -d"/" -f-4

nix-info-nixops:
	@$(MAKE) --no-print-directory -C nixops/ nix-info

nur:
	./scripts/make-nur
	curl -o /dev/null -XPOST "https://nur-update.herokuapp.com/update?repo=immae"

shellcheck:
	shellcheck scripts/* nixops/scripts/* modules/private/gitolite/gitolite_ldap_groups.sh modules/private/ssh/ldap_authorized_keys.sh modules/private/pub/restrict

.PHONY: env env-dry-run nix-info nur shellcheck
