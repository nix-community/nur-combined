{
  lib,
  stdenv,
  steamacSrc,
  moltenvkSrc,
  spirvCross,
  spirv-tools,
  spirv-headers,
  vulkan-headers,
  cereal,
  glslang,
  apple-sdk_26,
  xcbuildHook,
}:

let
  patchDir = "${steamacSrc}/host/moltenvk/patches/moltenvk";
  patches = lib.sort (a: b: a < b) (
    builtins.filter (p: lib.hasSuffix ".patch" p) (lib.filesystem.listFilesRecursive patchDir)
  );
  arch = stdenv.hostPlatform.darwinArch;
in

# UTM's MoltenVK fork (geometry shaders, robustBufferAccess2, ...) plus the
# Steamac patch series. Built with xcbuild against nixpkgs' Apple SDK,
# SPIRV-Tools/Headers, cereal, glslang and Steamac's patched SPIRV-Cross,
# following nixpkgs' MoltenVK recipe instead of upstream's `make macos`.
stdenv.mkDerivation (finalAttrs: {
  pname = "moltenvk-steamac";
  version = "1.4.1-utm";

  src = moltenvkSrc;

  inherit patches;

  nativeBuildInputs = [ xcbuildHook ];

  buildInputs = [
    apple-sdk_26
    cereal
    glslang
    spirvCross
    spirv-headers
    spirv-tools
    vulkan-headers
  ];

  postPatch = ''
    # Version of both patch series, part of VkPhysicalDeviceProperties
    # ::pipelineCacheUUID (MoltenVK's "pipeline cache UUID" patch).
    patch_rev=$(cat ${steamacSrc}/host/moltenvk/patches/moltenvk/*.patch \
      ${steamacSrc}/host/moltenvk/patches/spirv-cross/*.patch | sha256sum | cut -c1-8)
    printf '// Generated for the Steamac Nix build\n#define MVK_PATCH_REVISION 0x%s\n' "$patch_rev" \
      > MoltenVK/MoltenVK/GPUObjects/MVKPatchRevision.h

    # The source tarball has no Git metadata, and the generated header has to
    # live somewhere the compiler can find it.
    mkdir -p build/include
    substituteInPlace Scripts/gen_moltenvk_rev_hdr.sh \
      --replace-fail '$(git rev-parse HEAD)' '${moltenvkSrc.rev}' \
      --replace-fail 'MVK_HDR_FILE="''${BUILT_PRODUCTS_DIR}/mvkGitRevDerived.h"' \
        "MVK_HDR_FILE=\"$PWD/build/include/mvkGitRevDerived.h\""

    # Update the deployment target for the minimum target used by nixpkgs.
    while IFS= read -d "" proj; do
      substituteInPlace "$proj" \
        --replace-fail 'MACOSX_DEPLOYMENT_TARGET = 12.0' "MACOSX_DEPLOYMENT_TARGET = $MACOSX_DEPLOYMENT_TARGET"
    done < <(grep -Z -rl --include=project.pbxproj MACOSX_DEPLOYMENT_TARGET)

    # xcbuild cannot parse scheme names containing spaces, so rename the
    # macOS packaging scheme.
    mv "MoltenVKPackaging.xcodeproj/xcshareddata/xcschemes/MoltenVK Package (macOS only).xcscheme" \
      MoltenVKPackaging.xcodeproj/xcshareddata/xcschemes/MoltenVK-macOS.xcscheme

    # Don't try to build xcframeworks because xcbuild can't build them.
    sed -e '/xcframework/d' -i Scripts/package_all.sh

    # Modify the Xcode projects to build with xcbuild and dependencies from
    # nixpkgs instead of the External xcframeworks.
    for proj in MoltenVK MoltenVKShaderConverter; do
      sed -E -e '/(children|files) = /,/;/{/xcframework/d}' \
        -i "$proj/$proj.xcodeproj/project.pbxproj"
      substituteInPlace "$proj/$proj.xcodeproj/project.pbxproj" \
        --replace-fail SPIRV_CROSS_NAMESPACE_OVERRIDE=MVK_spirv_cross SPIRV_CROSS_NAMESPACE_OVERRIDE=spirv_cross
    done
    # The fork still uses the old MetalGL product names; align them with what
    # the tool target and the dylib link line expect.
    substituteInPlace MoltenVKShaderConverter/MoltenVKShaderConverter.xcodeproj/project.pbxproj \
      --replace-fail MetalGLShaderConverterTool MoltenVKShaderConverter \
      --replace-fail MetalGLShaderConverter-macOS MoltenVKShaderConverter

    # Some of the fork's patches spell out the SPIRV-Cross namespace that its
    # own External build uses; we link nixpkgs' spirv-cross instead.
    grep -rl MVK_spirv_cross MoltenVK MoltenVKShaderConverter | xargs sed -i 's/MVK_spirv_cross/spirv_cross/g'

    # Remove vendored dependency links.
    find . -lname '*/External/*' -delete

    # MoltenVKShaderConverter needs non-public glslang headers.
    ln -s ${glslang.src} build/include/glslang
  '';

  env.NIX_CFLAGS_COMPILE = toString (
    # MoltenVK does its own checks for availability by probing the version at
    # runtime and checking the MSL version.
    [ "-Wno-error=unguarded-availability" ]
    ++ lib.optional (
      stdenv.cc.libcxx != null
    ) "-isystem ${lib.getInclude stdenv.cc.libcxx}/include/c++/v1"
    ++ [
      "-I${lib.getDev spirvCross}/include/spirv_cross"
      "-I${lib.getDev spirv-headers}/include/spirv/unified1"

      # MoltenVK prints a lot of verbose output to the console out of the
      # box; we adjust this to match Homebrew's default log level.
      "-DMVK_CONFIG_LOG_LEVEL=MVK_CONFIG_LOG_LEVEL_NONE"
    ]
  );

  env.NIX_LDFLAGS = toString [
    "-lglslang"
    "-lSPIRV"
    "-lSPIRV-Tools"
    "-lSPIRV-Tools-opt"
    "-lspirv-cross-msl"
    "-lspirv-cross-core"
    "-lspirv-cross-glsl"
    "-lspirv-cross-reflect"
  ];

  preBuild = ''
    NIX_CFLAGS_COMPILE+=" \
      -I$PWD/build/include \
      -I$PWD/Common"
  '';

  xcbuildFlags = [
    "-configuration"
    "Release"
    "-project"
    "MoltenVKPackaging.xcodeproj"
    "-scheme"
    "MoltenVK-macOS"
    "-destination"
    "generic/platform=macOS"
    "-arch"
    arch
  ];

  postBuild = ''
    # MoltenVK's Xcode project builds the static library, but its dylib target
    # does not work with xcbuild. Link the dylib the way upstream's script did
    # before 1.2.8 (same as nixpkgs' MoltenVK).
    mkdir -p Package/Release/MoltenVK/dynamic/dylib
    clang++ -Wl,-all_load -Wl,-w \
      -dynamiclib \
      -compatibility_version 1.0.0 -current_version 1.0.0 \
      -LProducts/Release \
      -framework AppKit \
      -framework CoreGraphics \
      -framework Foundation \
      -framework IOKit \
      -framework IOSurface \
      -framework Metal \
      -framework QuartzCore \
      -lobjc \
      -lMoltenVKShaderConverter \
      -install_name "@rpath/libMoltenVK.dylib" \
      -o Package/Release/MoltenVK/dynamic/dylib/libMoltenVK.dylib \
      -force_load Products/Release/libMoltenVK.a
  '';

  installPhase = ''
    runHook preInstall

    pkg=Package/Release/MoltenVK
    built=$pkg/dynamic/dylib

    mkdir -p "$out/lib" "$out/share/vulkan/icd.d" "$out/include"
    cp "$built/libMoltenVK.dylib" "$out/lib/libMoltenVK.dylib"
    cp -R MoltenVK/include/MoltenVK "$out/include/MoltenVK"

    sed 's#"library_path"[[:space:]]*:[[:space:]]*"[^"]*"#"library_path": "../../../lib/libMoltenVK.dylib"#' \
      MoltenVK/icd/MoltenVK_icd.json > "$out/share/vulkan/icd.d/MoltenVK_icd.json"

    # build.sh reads MVK_PATCH_REVISION from here and embeds it in the app's
    # Info.plist (SteamacMVKPatchRevision) for crash reports.
    {
      echo "MoltenVK for steamac (host Venus renderer), built by the Nix package"
      echo
      echo "source:  https://github.com/utmapp/MoltenVK"
      echo "commit:  ${moltenvkSrc.rev}"
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
