{
  lib,
  stdenv,
  steamacSrc,
  libkrunVersion,
  libkrunSrc,
  libkrunSysroot,
  libepoxy,
  virglrenderer,
  rustc,
  cargo,
  rustPlatform,
  pkg-config,
  dtc,
  xz,
  lld,
}:

let
  patchDir = "${steamacSrc}/host/libkrun/patches";

  patches = lib.sort (a: b: a < b) (
    builtins.filter (p: lib.hasSuffix ".patch" p) (lib.filesystem.listFilesRecursive patchDir)
  );

  # The Steamac patch series bumps crates (e.g. imago to 0.2.6), so vendor
  # from the patched tree rather than from the pristine Cargo.lock.
  cargoDeps = rustPlatform.fetchCargoVendor {
    name = "libkrun-cargo-deps";
    src = libkrunSrc;
    inherit patches;
    hash = "sha256-jcXGbOdlV+3yTQQDOGQD2V6ALJDTqKjp2Ocs6EdTXiY=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "libkrun-steamac";
  version = libkrunVersion;

  src = libkrunSrc;

  inherit patches;

  nativeBuildInputs = [
    cargo
    rustc
    pkg-config
    dtc
    xz
    lld
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libepoxy
    virglrenderer
  ];

  dontConfigure = true;

  postPatch = ''
    # With no variant selected, KRUN_BASE_Darwin is plain libkrun.dylib, so
    # the recipe's `mv libkrun.dylib libkrun.dylib` fails on a same-file move.
    substituteInPlace Makefile --replace-fail \
      'mv target/release/libkrun.dylib target/release/$(KRUN_BASE_$(OS))' \
      'test "target/release/libkrun.dylib" -ef "target/release/$(KRUN_BASE_$(OS))" || mv target/release/libkrun.dylib target/release/$(KRUN_BASE_$(OS))'
  '';

  # The Makefile compiles the Linux init blob with /usr/bin/clang and Xcode's
  # headers, outside the Nix store.
  __noChroot = true;

  preBuild = ''
    export CARGO_HOME=$TMPDIR/cargo-home
    mkdir -p .cargo
    # fetchCargoVendor writes the source-replacement config; point it at the
    # store copy of the vendored crates.
    printf '\n' >> .cargo/config.toml
    sed "s|@vendor@|${cargoDeps}|g" "${cargoDeps}/.cargo/config.toml" >> .cargo/config.toml
    printf '\n' >> .cargo/config.toml

    export CARGO_NET_OFFLINE=true
    # Do not fall back to Homebrew/global pkg-config paths.
    export PKG_CONFIG_PATH="${virglrenderer}/lib/pkgconfig:${libepoxy}/lib/pkgconfig"
    export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
    export SYSROOT_LINUX=${libkrunSysroot}/sysroot
    export MACOSX_DEPLOYMENT_TARGET=15.0
    # No rustc strip: its llvm-objcopy debuginfo strip leaves
    # LC_SYMTAB.stroff 4-byte aligned, which dyld rejects for macOS 27 SDK
    # images (rust-lang/rust#157750).
    export CARGO_PROFILE_RELEASE_STRIP=false
  '';

  buildPhase = ''
    runHook preBuild
    # No .git in the Nix source, so the Makefile cannot derive its version
    # from `git describe`.
    make GPU=1 BLK=1 NET=1 INPUT=1 SND=1 VERSION=${libkrunVersion}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    make PREFIX="$out" VERSION=${libkrunVersion} install

    install_name_tool -id @rpath/libkrun.1.dylib "$out/lib/libkrun.${libkrunVersion}.dylib"
    codesign --force -s - "$out/lib/libkrun.${libkrunVersion}.dylib"
    runHook postInstall
  '';

  dontFixup = true;

  meta = {
    description = "Lightweight VMM library used by the Steamac launcher";
    homepage = "https://github.com/libkrun/libkrun";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
  };
})
