.CLONE:
	./partial-clone.sh https://github.com/NixOS/nixpkgs pkgs/development/tools/misc/universal-ctags pkgs/universal-ctags-pcre2
	touch .CLONE

pkgs/universal-ctags-pcre2/default.nix: .CLONE
	patch -N < patches/universal-ctags-pcre2.patch pkgs/universal-ctags-pcre2/default.nix

.PHONY: clean all pkgs/universal-ctags-pcre2/default.nix

clean:
	rm -rf pkgs/universal-ctags-pcre2
	rm .CLONE

all: pkgs/universal-ctags-pcre2/default.nix