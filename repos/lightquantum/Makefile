REMOTE_universal-ctags-pcre2 := pkgs/development/tools/misc/universal-ctags

PATCH_PKGS = universal-ctags-pcre2
PATCH_PKGS_DIRS = $(addprefix pkgs/, $(PATCH_PKGS))
PATCH_PKGS_TARGETS = $(addsuffix /default.nix, $(PATCH_PKGS_DIRS))

.CLONE/%:
	@echo "[+] Cloning $(REMOTE_$*) into pkgs/$*"
	rm -rf "pkgs/$*"
	./partial-clone.sh https://github.com/NixOS/nixpkgs "$(REMOTE_$*)" "pkgs/$*"
	mkdir -p .CLONE
	touch "$@"

pkgs/%/default.nix: .CLONE/% patches/%.patch
	@echo "[+] Patching $*"
	patch -N < "patches/$*.patch" "pkgs/$*/default.nix"

.PHONY: clean all PATCH_PKGS_TARGETS

all: $(PATCH_PKGS_TARGETS)

clean:
	rm -rf $(PATCH_PKGS_DIRS)
	rm -rf temp-clone
	rm -rf .CLONE
