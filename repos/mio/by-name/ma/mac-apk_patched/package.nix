{
  mac-apk,
  apple-sdk_15,
}:

mac-apk.overrideAttrs (old: {
  pname = "mac-apk_patched";

  patches = (old.patches or [ ]) ++ [
    ../mac-apk/macos15-nix.patch
    ../mac-apk/stack-chk-fail-no-recovery-frame.patch
  ];

  buildInputs = (old.buildInputs or [ ]) ++ [ apple-sdk_15 ];

  buildPhase = ''
    export MACAPK_USE_NIX_SDK=1
    export SDKROOT="${apple-sdk_15}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
    export NIX_APPLE_SDK_VERSION=150500
    ${old.buildPhase}
  '';

  meta = (old.meta or { }) // {
    description = "Run Android APKs natively on Apple Silicon macOS 15 and later";
  };
})
