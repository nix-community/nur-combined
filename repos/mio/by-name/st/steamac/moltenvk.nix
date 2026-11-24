{
  lib,
  stdenv,
  steamacSrc,
  moltenvkSrc,
  moltenvkDeps,
  xz,
}:

let
  patchDir = "${steamacSrc}/host/moltenvk/patches/moltenvk";
  patches = lib.sort (a: b: a < b) (
    builtins.filter (p: lib.hasSuffix ".patch" p) (lib.filesystem.listFilesRecursive patchDir)
  );
in

# UTM's MoltenVK fork (geometry shaders, robustBufferAccess2, ...) plus the
# Steamac patch series, built the way upstream's host/moltenvk/build.sh does:
# fetchDependencies first, then `make macos` (Release, universal) and the arm64
# slice.
stdenv.mkDerivation (finalAttrs: {
  pname = "moltenvk-steamac";
  version = "1.4.1-utm";

  src = moltenvkSrc;

  inherit patches;

  nativeBuildInputs = [ xz ];

  dontConfigure = true;

  # xcodebuild and the Metal toolchain live in Xcode, outside the Nix store.
  __noChroot = true;

  postPatch = ''
    # Version of both patch series, part of VkPhysicalDeviceProperties
    # ::pipelineCacheUUID (MoltenVK's "pipeline cache UUID" patch).
    patch_rev=$(cat ${steamacSrc}/host/moltenvk/patches/moltenvk/*.patch \
      ${steamacSrc}/host/moltenvk/patches/spirv-cross/*.patch | sha256sum | cut -c1-8)
    printf '// Generated for the Steamac Nix build\n#define MVK_PATCH_REVISION 0x%s\n' "$patch_rev" \
      > MoltenVK/MoltenVK/GPUObjects/MVKPatchRevision.h
  '';

  buildPhase = ''
    runHook preBuild

    cp -R ${moltenvkDeps}/External External

    export HOME="$PWD/.home"
    mkdir -p "$HOME"
    # Same environment scrub as upstream: no Homebrew/SDK variables leak into
    # xcodebuild. Metal is found through xcrun. CFFIXED_USER_HOME is what
    # CoreFoundation uses for NSHomeDirectory(); the Nix build user's passwd
    # home is /var/empty, which xcodebuild cannot write DerivedData into.
    env -i \
      PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
      HOME="$HOME" \
      CFFIXED_USER_HOME="$HOME" \
      LANG=en_US.UTF-8 \
      make macos

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

    pkg=Package/Release/MoltenVK
    built=$pkg/dynamic/dylib/macOS

    mkdir -p "$out/lib" "$out/share/vulkan/icd.d" "$out/include"
    lipo "$built/libMoltenVK.dylib" -thin arm64 -output "$out/lib/libMoltenVK.dylib"
    install_name_tool -id @rpath/libMoltenVK.dylib "$out/lib/libMoltenVK.dylib"
    codesign --force -s - "$out/lib/libMoltenVK.dylib"

    sed 's#"library_path"[[:space:]]*:[[:space:]]*"[^"]*"#"library_path": "../../../lib/libMoltenVK.dylib"#' \
      "$built/MoltenVK_icd.json" > "$out/share/vulkan/icd.d/MoltenVK_icd.json"
    cp -R "$pkg/include/MoltenVK" "$out/include/MoltenVK"

    # build.sh reads MVK_PATCH_REVISION from here and embeds it in the app's
    # Info.plist (SteamacMVKPatchRevision) for crash reports.
    {
      echo "MoltenVK for steamac (host Venus renderer), built by the Nix package"
      echo
      echo "source:  https://github.com/utmapp/MoltenVK"
      echo "commit:  05604465d691118cfd20f53a48ecf1aad9c12f93"
      echo
      echo "MoltenVK patches:"
      for p in ${patchDir}/*.patch; do echo "  $(basename "$p")"; done
      echo
      echo "MVK patch revision:"
      echo "MVK_PATCH_REVISION ($(sed -n 's/^#define MVK_PATCH_REVISION 0x//p' MoltenVK/MoltenVK/GPUObjects/MVKPatchRevision.h))"
    } > "$out/MOLTENVK.txt"

    runHook postInstall
  '';

  dontFixup = true;

  meta = {
    description = "MoltenVK fork used by the Steamac host Venus renderer";
    homepage = "https://github.com/utmapp/MoltenVK";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
  };
})
