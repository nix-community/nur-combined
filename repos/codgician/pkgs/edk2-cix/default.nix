{
  lib,
  pkgsCross,
  gcc14Stdenv,
  fetchFromGitHub,
  acpica-tools,
  glibc,
  libuuid,
  patchelf,
  python3,
  nix-update-script,
}:

gcc14Stdenv.mkDerivation (finalAttrs: {
  pname = "edk2-cix";
  version = "1.1.0-2";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "radxa-pkg";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-EAB3cA5bD1cWx66uUL6auwn9Ihe2dXXRq/wxULT4ahk=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  hardeningDisable = [
    "format"
    "fortify"
    "trivialautovarinit"
  ];

  depsBuildBuild = [ gcc14Stdenv.cc ];

  nativeBuildInputs = [
    acpica-tools
    libuuid
    patchelf
    python3
  ]
  ++ (lib.optional (
    gcc14Stdenv.hostPlatform.system != "aarch64-linux"
  ) pkgsCross.aarch64-multiplatform.gcc14Stdenv.cc);

  buildInputs = [
    gcc14Stdenv.cc.cc.lib
  ];

  GCC5_AARCH64_PREFIX = pkgsCross.aarch64-multiplatform.gcc14Stdenv.cc.targetPrefix;

  postPatch =
    let
      inherit (gcc14Stdenv.hostPlatform) system;
      archPath =
        if system == "x86_64-linux" then
          "X86_64"
        else if system == "aarch64-linux" then
          "AARCH64"
        else
          throw "Unsupported build platform: ${system}";
    in
    ''
      # Patch the pre-built binaries in edk2-non-osi before they're used
      # These are build tools that run on the build host, which may be skipped 
      # by autoPatchelf due to architecture mismatch, so we patch manually
      for bin in edk2-non-osi/Platform/CIX/Sky1/PackageTool/${archPath}/*; do
        if [ -f "$bin" ] && [ -x "$bin" ]; then
          echo "Patching package tool: $bin"
          patchelf --set-interpreter ${glibc}/lib/ld-linux* --set-rpath ${glibc}/lib "$bin" || true
        fi
      done

      substituteInPlace ./Makefile \
        --replace-fail 'GCC5_AARCH64_PREFIX := aarch64-linux-gnu-' \
                       'GCC5_AARCH64_PREFIX := ${pkgsCross.aarch64-multiplatform.gcc14Stdenv.cc.targetPrefix}'
                      
      patchShebangs .    
    '';

  preBuild = ''
    # Create directories that the Makefile expects to exist
    mkdir -p Build/O6/RELEASE_GCC5/Firmwares
    mkdir -p Build/O6N/RELEASE_GCC5/Firmwares
  '';

  enableParallelBuilding = false;

  installPhase = ''
    runHook preInstall

    # Install both O6 and O6N builds
    for target in O6:orion-o6 O6N:orion-o6n; do
      IFS=: read -r build_target install_name <<< "$target"
      
      install_dir="$out/share/edk2/radxa/$install_name"
      mkdir -p "$install_dir"

      # Copy firmware binaries and build artifacts
      cp -r Build/$build_target/RELEASE_GCC5/cix_flash*.bin "$install_dir"/
      cp -r Build/$build_target/RELEASE_GCC5/BuildOptions "$install_dir"/
      cp -r Build/$build_target/RELEASE_GCC5/AARCH64/VariableInfo.efi "$install_dir"/
      cp -r Build/$build_target/RELEASE_GCC5/AARCH64/Shell.efi "$install_dir"/

      # Copy flash tools
      cp -r edk2-non-osi/Platform/CIX/Sky1/FlashTool/* "$install_dir"/

      # Copy scripts
      cp -r scripts/* "$install_dir"/
    done

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "EDK2 for CIX platforms";
    homepage = finalAttrs.src.url;
    maintainers = with lib.maintainers; [ codgician ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
