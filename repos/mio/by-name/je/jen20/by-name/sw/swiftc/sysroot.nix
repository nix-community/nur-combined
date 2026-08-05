{
  lib,
  apple-sdk,
  libc,
  lndir,
  linkFarm,
  llvmPackages_current,
  symlinkJoin,
  stdenv,
  swift_release,
}:

# This derivation creates a sysroot usable with Swift. This is easier and more robust than trying to teach the unwrapped
# compiler how to understand the `NIX_` variables that inject libraries into the path.

# Platform specifics:
# * Darwin - Injects libc++ headers back into the SDK at the expected path.
# * Linux - Creates a simple sysroot consisting of libc and libstdc++ or libc++ (depending on the stdenv configuration).

let
  sysrootBase =
    if stdenv.hostPlatform.isDarwin then
      "Platforms/MacOSX.platform/Developer/SDKs/MacOSX${lib.getVersion apple-sdk}.sdk/usr"
    else
      "usr";

  rebase =
    basePath: drv:
    stdenv.mkDerivation (finalAttrs: {
      pname = lib.getName drv + "-for-sysroot";
      version = lib.getVersion drv;

      outputs = drv.outputs or [ "out" ];
      drvOutputs = lib.genAttrs finalAttrs.outputs (output: (lib.getOutput output drv).outPath);

      nativeBuildInputs = [ lndir ];

      strictDeps = true;

      buildCommand = ''
        for output in "''${!outputs[@]}"; do
          echo "output: $output"
          rebasedPath="''${outputs[$output]}/${basePath}"
          echo "rebasedPath: $rebasedPath"
          mkdir -p "$rebasedPath"
          echo "Doing an lndir from “''${drvOutputs[$output]}” to “$rebasedPath”"
          lndir "''${drvOutputs[$output]}" "$rebasedPath"
        done
      '';

      __structuredAttrs = true;
    });

  #  libc = linkFarm "sysroot-libc" {
  #    "usr/lib"
  #  }

  sysroot = symlinkJoin {
    pname = "sysroot-for-swift";
    version = swift_release;

    paths = [
      apple-sdk.out
      (lib.getDev (rebase sysrootBase llvmPackages_current.stdenv.cc.libcxx))
    ];
  };
in
stdenv.mkDerivation {
  inherit (sysroot) pname version;

  buildCommand = ''
    mkdir -p "$out"
    cp -r ${lib.escapeShellArg sysroot}/* "$out"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    chmod -R u+w "$out/Platforms/MacOSX.platform" "$out/nix-support"

    # xcrun uses these to find the location of the SDK. It does the wrong thing when they’re symlinks.
    declare -a files=(
      Info.plist
      Developer/SDKs/MacOSX.sdk/SDKSettings.json
      Developer/SDKs/MacOSX.sdk/SDKSettings.plist
      Developer/SDKs/MacOSX.sdk/Entitlements.plist
    )
    for file in "''${files[@]}"; do
      filePath=$out/Platforms/MacOSX.platform/$file
      orig=$(readlink "$filePath")
      rm "$filePath"
      cp "$orig" "$filePath"
    done

    # Fix up the setup-hook in the SDK to point back to this sysroot instead of using the original SDK.
    orig=$(readlink "$out/nix-support/setup-hook")
    rm "$out/nix-support/setup-hook"
    substitute "$orig" "$out/nix-support/setup-hook" \
      --replace-fail ${lib.escapeShellArg apple-sdk.out} "$out"

    chmod -R u-w "$out/Platforms/MacOSX.platform" "$out/nix-support"
  '';
}
#stdenv.mkDerivation {
#  pname = "sysroot-for-swift";
#  version = swift_release;
#
#  buildCommand = if stdenv.hostPlatform.isDarwin then ''
#    sysrootBase=Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr
#  '' else ''
#    sysrootBase=usr
#  ''
#  + ''
#    mkdir -p "
#  '';
#}
