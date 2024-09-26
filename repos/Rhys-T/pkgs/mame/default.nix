{ mame, lib }: let
    mameForArgSpecs = mame;
    mameArgSpecs = lib.mapAttrs (k: v: true) (lib.functionArgs mameForArgSpecs.override);
    myArgSpecs = lib.functionArgs mameFunc;
    mameFunc = (
        { stdenv, callPackage, papirus-icon-theme, mame, darwinMinVersion ? "10.15", overrideSDK, ... }@args: let
            stdenv' = overrideSDK stdenv {
                darwinMinVersion = "10.15";
                darwinSdkVersion = "11.0";
            };
            mame-icon = if (builtins.tryEval "${papirus-icon-theme}").success then
                papirus-icon-theme
            else
                callPackage ./icon.nix {};
            thruArgs = builtins.intersectAttrs mameArgSpecs (args // { papirus-icon-theme = mame-icon; });
            needToChangeStdenv = stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion darwinMinVersion;
            mame' = mame.override (thruArgs // lib.optionalAttrs needToChangeStdenv {
                stdenv = stdenv';
            });
            needToRemoveMetal = stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinMinVersion "11.0";
            mame'' = if needToRemoveMetal then mame'.overrideAttrs (old: {
                env = (old.env or {}) // {
                    NIX_CFLAGS_COMPILE = (old.env.NIX_CFLAGS_COMPILE or "") + " -DBGFX_CONFIG_RENDERER_METAL=0";
                };
            }) else mame';
            mame''' = mame''.overrideAttrs (old: {
                meta = (old.meta or {}) // {
                    # description = "${old.meta.description or "MAME"} (fixed for macOS/Darwin)";
                    broken = false;
                };
            });
        in mame'''
    );
in lib.setFunctionArgs mameFunc (myArgSpecs // mameArgSpecs)
