{lib, newScope, callPackage, version, rev ? "v${version}", hash ? null, dataHash ? null, mods ? []}@args:
let
    scope = lib.makeScope newScope (self: let inherit (self) callPackage; in {
        inherit version rev hash dataHash;
        unwrapped = callPackage ./unwrapped.nix {
            _pos = builtins.unsafeGetAttrPos "version" args;
        };
        data = callPackage ./data.nix {};
        wrapTuxemon = callPackage ./wrapper.nix {};
        pkgs = scope;
        # 'Borrowed' from nixpkgs cataclysm-dda derivations
        attachPkgs = pkgs: super: let self = super.overrideAttrs (old: {
            passthru = (old.passthru or {}) // {
                inherit pkgs;
                withMods = pkgs.wrapTuxemon self;
            };
        }); in self;
    });
in scope.unwrapped
