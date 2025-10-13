{stdenv, lib, makeSetupHook, fmt}: makeSetupHook {
    name = "fuzziqersoftware-fmt-patch-hook";
    depsTargetTargetPropagated = [fmt];
    passthru = {
        inherit fmt;
        isNeeded =
            stdenv.cc.isClang && stdenv.cc.libcxx != null && (let
                libcxxVersion = lib.getVersion stdenv.cc.libcxx;
            in if lib.hasInfix "+apple" libcxxVersion then
                # <https://github.com/NixOS/nixpkgs/pull/398727> switched libcxx to Apple's version.
                # This implements std::format on top of to_chars, which doesn't exist until 13.3.
                lib.versionOlder stdenv.hostPlatform.darwinMinVersion "13.3"
            else
                # Using LLVM's libcxx, which has its own to_chars.
                lib.versionOlder libcxxVersion "17"
            )
        ;
    };
} ./hook.sh
