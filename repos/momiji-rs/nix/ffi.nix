# The C ABI as a Nix package: `libsasso.{so,dylib}`, `libsasso.a`, `sasso.h` and
# a pkg-config file, so a Nix consumer can *build against* sasso instead of only
# running it (issue #82) —
#
#   buildInputs = [ pkgs.sasso-ffi ];   # -lsasso, <sasso.h>, `pkg-config sasso`
#
# Rust callers need none of this: they take the crate from crates.io through
# their own `Cargo.lock`. Everything else with a C FFI does — PHP FFI, Python
# ctypes/cffi, Ruby Fiddle, Go cgo, LuaJIT, .NET — see ../ffi/README.md.
#
# This output is flake-only on purpose. nixpkgs packages the CLI, which is what
# a distribution is for; shipping a second, library-shaped derivation costs
# nothing here and needs no upstream review.
{
  lib,
  stdenv,
  rustPlatform,
  python3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sasso-ffi";

  # The WRAPPER's version, not the compiler's — ../ffi/Cargo.toml explains why
  # they are allowed to differ (`sasso_version()` reports the compiler's).
  version = (lib.importTOML ../ffi/Cargo.toml).package.version;

  src = lib.cleanSource ../.;

  # ../ffi is its own workspace (it needs the `unsafe` the core crate denies),
  # so cargo runs there rather than at the tree root.
  buildAndTestSubdir = "ffi";

  # ffi/Cargo.lock is deliberately untracked (see ../ffi/.gitignore), so the
  # root lock seeds the vendor directory. That works because the wrapper's only
  # dependency is the core crate BY PATH and the core crate has no runtime
  # dependencies at all: there is nothing to fetch that the root lock misses.
  cargoLock.lockFile = ../Cargo.lock;

  # A cdylib+staticlib crate has no test target of its own; the real check is
  # the one below, which drives the built library through the C ABI.
  doCheck = false;

  postInstall = ''
    install -Dm444 ffi/include/sasso.h -t $out/include

    mkdir -p $out/lib/pkgconfig
    cat > $out/lib/pkgconfig/sasso.pc <<EOF
    prefix=$out
    libdir=\''${prefix}/lib
    includedir=\''${prefix}/include

    Name: sasso
    Description: C ABI for the sasso SCSS to CSS compiler
    Version: ${finalAttrs.version}
    Libs: -L\''${libdir} -lsasso
    Cflags: -I\''${includedir}
    EOF
  '';

  # The ABI's own smoke test — the one CI runs — but pointed at the INSTALLED
  # library rather than the build tree, so it checks what consumers get.
  # `examples/smoke.py` looks for `libsasso.*` beside ffi/, hence the link.
  nativeInstallCheckInputs = [ python3 ];
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    ln -sf $out/lib/libsasso${stdenv.hostPlatform.extensions.sharedLibrary} ffi/
    python3 ffi/examples/smoke.py
    runHook postInstallCheck
  '';

  meta = {
    description = "C ABI for the sasso SCSS to CSS compiler";
    homepage = "https://github.com/momiji-rs/sasso";
    changelog = "https://github.com/momiji-rs/sasso/blob/master/ffi/README.md";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
