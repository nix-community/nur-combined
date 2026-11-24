# libghostty-vt, built from Ghostty's standalone VT library release and
# installed the way cutefish-terminal looks for it: a static library, the C
# headers, and a pkg-config module named cutefish-ghostty-vt.
#
# The build is upstream's own (PACKAGING-LIBGHOSTTY.md in the release tarball):
# zig build with the release's dependency tarball as the --system package
# directory, so no part of the build touches the network. The static-library
# layout and the pkg-config module come from debian/cutefish-ghostty-vt in
# cutefishos/packaging; upstream's own pkg-config and CMake files carry the
# common libghostty-vt names, so they are dropped here.
#
# There is no passthru.updateScript: release.files.ghostty.org publishes the
# libghostty-vt tarballs without a directory index or version feed, so there is
# nothing for nix-update to follow. To bump, change `version` and refresh both
# hashes with `nix store prefetch-file <url>`.
{
  lib,
  stdenv,
  fetchurl,
  runCommand,
  zig_0_17,
}:

let
  version = "1.0.1";

  depsTarball = fetchurl {
    url = "https://release.files.ghostty.org/libghostty-vt/${version}/libghostty-vt-${version}-deps.tar.gz";
    hash = "sha256-kaThCWClK/W/SxWqKizdr/ionWzZA9MFW9pP0X3jNW0=";
  };

  # A package directory of its own: Zig reads the packages from here, and the
  # build cache the zig hook sets up stays empty.
  deps = runCommand "libghostty-vt-${version}-deps" { } ''
    mkdir -p $out
    tar xzf ${depsTarball} -C $out --strip-components=1
  '';

  zigFlags = [
    "--system"
    "${deps}"
    "-Dcpu=baseline"
    "-Doptimize=ReleaseFast"
  ];

  # The tests run in the default Debug mode, as upstream's recipe does: in a
  # ReleaseFast build `inlineAssert` compiles to `unreachable`, and tests that
  # exercise an assert fail to compile instead of running.
  zigTestFlags = [
    "--system"
    "${deps}"
    "-Dcpu=baseline"
  ];
in
stdenv.mkDerivation {
  pname = "cutefish-ghostty-vt";
  inherit version;

  src = fetchurl {
    url = "https://release.files.ghostty.org/libghostty-vt/${version}/libghostty-vt-${version}.tar.gz";
    hash = "sha256-Mz386XZB75tTa7ngiQethquqraUOj3QXtw2ShK3vN6o=";
  };

  strictDeps = true;

  nativeBuildInputs = [ zig_0_17 ];

  dontSetZigDefaultFlags = true;

  zigBuildFlags = zigFlags;

  # The library's tests are a step of their own; the hook's default check would
  # run the `test` step, which only the Ghostty app build defines.
  doCheck = true;

  checkPhase = ''
    runHook preCheck
    zig build test-lib-vt ${lib.escapeShellArgs zigTestFlags} --verbose
    runHook postCheck
  '';

  postInstall = ''
    # Only the static library and the headers are needed. Dropping the shared
    # library, the CMake package config and upstream's pkg-config files keeps
    # the common libghostty-vt names free for a distribution's own copy.
    rm -rf "$out/lib/libghostty-vt".so* "$out/lib/cmake" "$out/lib/pkgconfig"

    mkdir -p "$out/lib/pkgconfig"
    cat > "$out/lib/pkgconfig/cutefish-ghostty-vt.pc" <<'EOF'
    libdir=${placeholder "out"}/lib
    includedir=${placeholder "out"}/include

    Name: cutefish-ghostty-vt
    Description: libghostty-vt, static, for building Cutefish
    URL: https://github.com/ghostty-org/ghostty
    Version: ${version}
    Cflags: -I''${includedir} -DGHOSTTY_STATIC
    Libs: -L''${libdir} -lghostty-vt -lm
    EOF
  '';

  meta = {
    description = "Ghostty's VT parsing library, built statically for cutefish-terminal";
    homepage = "https://github.com/ghostty-org/ghostty";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
