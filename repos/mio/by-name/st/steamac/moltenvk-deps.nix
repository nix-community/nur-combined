{
  lib,
  stdenv,
  moltenvkSrc,
  spirvCross,
  spirvTools,
  spirvHeaders,
  volk,
  vulkanHeaders,
  vulkanTools,
  cereal,
  xz,
  python3,
}:

# MoltenVK's own fetchDependencies clones and builds the pinned external
# projects (SPIRV-Tools, Vulkan-Headers, cereal, ...) into External/. Fetch the
# exact revisions with Nix and let the script build them offline. This is not a
# fixed-output derivation because the SPIRV-Tools static library embeds the
# build directory, which differs between builds.
stdenv.mkDerivation {
  pname = "MoltenVK-deps";
  version = "1.4.1-utm";

  src = moltenvkSrc;

  nativeBuildInputs = [
    python3
    xz
  ];

  dontConfigure = true;

  # fetchDependencies runs xcodebuild and reads Xcode outside the Nix store.
  __noChroot = true;

  postPatch = ''
    # fetchDependencies ends with `make clean`, whose xcodebuild invocation
    # writes to the nixbld user's (unwritable) passwd home. Our MoltenVK build
    # starts from a fresh tree, so the clean is not needed.
    substituteInPlace Scripts/package_ext_libs_finish.sh \
      --replace-fail 'make --quiet clean' ':'

    CEREAL_SRC=${cereal} \
    SPIRV_CROSS_SRC=${spirvCross} \
    SPIRV_TOOLS_SRC=${spirvTools} \
    SPIRV_HEADERS_SRC=${spirvHeaders} \
    VOLK_SRC=${volk} \
    VULKAN_HEADERS_SRC=${vulkanHeaders} \
    VULKAN_TOOLS_SRC=${vulkanTools} \
      python3 ${./patch-fetchdeps.py} fetchDependencies
  '';

  buildPhase = ''
    runHook preBuild

    # xcodebuild writes its DerivedData/log store under HOME; the Nix build's
    # default HOME is not writable.
    export HOME="$PWD/.home"
    mkdir -p "$HOME"
    # Same environment scrub as upstream's build script: no Homebrew/SDK
    # variables may leak into xcodebuild.
    env -i \
      PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
      HOME="$HOME" \
      LANG=en_US.UTF-8 \
      ./fetchDependencies --macos --spirv-cross-root ${spirvCross}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R External "$out/External"
    # The MoltenVK build only needs the XCFrameworks and headers.
    rm -f "$out"/External/dependenciesbuild.log "$out"/External/*/*.log

    runHook postInstall
  '';

  meta = {
    description = "Pinned external dependencies for Steamac's MoltenVK fork";
    platforms = [ "aarch64-darwin" ];
  };
}
