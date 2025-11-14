{ mame, lib }: let
    mameArgSpecs = lib.mapAttrs (k: v: true) (lib.functionArgs mame.override);
    myArgSpecs = lib.functionArgs mameFunc;
    mameFunc = { stdenv, callPackage, papirus-icon-theme, darwinMinVersion ? "10.15", apple-sdk_11 ? null, darwinMinVersionHook, ... }@args: let
        mame-icon = if (builtins.tryEval "${papirus-icon-theme}").success then
            papirus-icon-theme
        else
            callPackage ./icon.nix {};
        thruArgs = builtins.intersectAttrs mameArgSpecs (args // { papirus-icon-theme = mame-icon; });
        mame' = mame.override thruArgs;
        needToRemoveMetal = let inherit (mame') stdenv; in stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion "11.0";
        mame'' = if needToRemoveMetal then mame'.overrideAttrs (old: {
            env = (old.env or {}) // {
                NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + " -DBGFX_CONFIG_RENDERER_METAL=0";
            };
        }) else mame';
        mame''' = mame''.overrideAttrs (old: {
            # Backported fix from NixOS/nixpkgs#401630:
            postPatch = (old.postPatch or "") + lib.optionalString (stdenv.hostPlatform.isDarwin && !(lib.hasInfix "sw_vers" (old.postPatch or ""))) ''
                for file in scripts/src/osd/{mac,sdl}.lua; do
                  substituteInPlace "$file" --replace-fail \
                    'backtick("sw_vers -productVersion")' \
                    "os.getenv('MACOSX_DEPLOYMENT_TARGET') or '$darwinMinVersion'"
                  done
            '';
            meta = (old.meta or {}) // {
                description = "${old.meta.description or "MAME"} (fixed for macOS/Darwin)";
                broken = false;
            };
        } // lib.optionalAttrs (stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion darwinMinVersion) {
            buildInputs = (old.buildInputs or []) ++ [apple-sdk_11 (darwinMinVersionHook darwinMinVersion)];
        });
    in mame''';
in lib.setFunctionArgs mameFunc (myArgSpecs // mameArgSpecs)
