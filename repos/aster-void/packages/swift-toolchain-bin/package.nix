# Claude-generated - use at your own risk
# because I don't know swift toolchain
{
  pkgs,
  stdenv,
  autoPatchelfHook,
  fetchurl,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "swift-toolchain";
  version = "6.2";

  src = fetchurl {
    url = "https://download.swift.org/swift-6.2-release/ubuntu2204/swift-6.2-RELEASE/swift-6.2-RELEASE-ubuntu22.04.tar.gz";
    hash = "sha256-cX3a8mUxa9WzcP5yAX8fTz9h74Z74e5j9bnQc1qV/XU=";
  };

  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    libgcc
    libuuid
    libz
    libxml2_13
    curl
    libedit
    libpanel
    python310
    sqlite
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libedit.so.2"
  ];

  installPhase = ''
    mkdir -p $out/bin-unwrapped
    mkdir -p $out/bin

    # Copy everything first
    cp -r usr/* $out/

    # Move original binaries
    mv $out/bin/* $out/bin-unwrapped/

    # Create a minimal SDK for Swift
    mkdir -p $out/sdk/usr/{include,lib}

    # Copy glibc headers (we need to modify tgmath.h)
    cp -r ${pkgs.glibc.dev}/include/* $out/sdk/usr/include/

    # Patch tgmath.h to work with Swift's clang
    # Remove the incompatibility check that fails with Swift
    sed -i '/#  error "Unsupported combination of types for <tgmath.h>."/d' $out/sdk/usr/include/tgmath.h || true

    # Copy libraries and startup files
    # Copy actual shared libraries (dereferencing symlinks)
    for lib in ${pkgs.glibc}/lib/*.so.* ${pkgs.glibc}/lib/*.a ${pkgs.glibc}/lib/*.o; do
      [ -f "$lib" ] && cp -L "$lib" $out/sdk/usr/lib/ 2>/dev/null || true
    done

    # Copy linker scripts and rewrite to use relative paths
    for script in ${pkgs.glibc}/lib/*.so; do
      if [ -f "$script" ] && head -1 "$script" | grep -q "GNU ld script"; then
        # Replace absolute paths with just filenames (relative to same directory)
        sed 's|/nix/store/[^/]*/lib/||g' "$script" > "$out/sdk/usr/lib/$(basename $script)"
      elif [ -f "$script" ]; then
        cp -L "$script" $out/sdk/usr/lib/ 2>/dev/null || true
      fi
    done

    cp -L ${stdenv.cc.cc.lib}/lib/*.{so,so.*,a} $out/sdk/usr/lib/ 2>/dev/null || true

    # Copy GCC runtime objects (crt*.o) and libgcc
    # Swift's clang needs these for linking
    for gcclib in ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/*; do
      if [ -d "$gcclib" ]; then
        cp -L $gcclib/*.{o,a,so,so.*} $out/sdk/usr/lib/ 2>/dev/null || true
      fi
    done

    # Copy Swift runtime to SDK
    mkdir -p $out/sdk/usr/lib/swift
    cp -r $out/lib/swift/linux $out/sdk/usr/lib/swift/

    # Wrap Swift binaries to use the SDK (only executable files)
    for prog in $out/bin-unwrapped/*; do
      progname=$(basename "$prog")
      if [ -f "$prog" ] && [ -x "$prog" ]; then
        if [ "$progname" = "swift-frontend" ]; then
          # Wrap swift-frontend with compiler flags
          makeWrapper $prog $out/bin/$progname \
            --prefix PATH : ${pkgs.lib.makeBinPath [stdenv.cc pkgs.git pkgs.curl]} \
            --set SDKROOT "$out/sdk" \
            --set LIBRARY_PATH "${pkgs.lib.makeLibraryPath [stdenv.cc.cc pkgs.glibc]}" \
            --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath [stdenv.cc.cc pkgs.glibc]}" \
            --add-flags "-Xcc" \
            --add-flags "-D__HAVE_FLOAT64X=0" \
            --add-flags "-Xcc" \
            --add-flags "-D__HAVE_FLOAT128=0"
        else
          # Other binaries don't get compiler flags
          makeWrapper $prog $out/bin/$progname \
            --prefix PATH : ${pkgs.lib.makeBinPath [stdenv.cc pkgs.git pkgs.curl]} \
            --set SDKROOT "$out/sdk" \
            --set LIBRARY_PATH "${pkgs.lib.makeLibraryPath [stdenv.cc.cc pkgs.glibc]}" \
            --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath [stdenv.cc.cc pkgs.glibc]}"
        fi
      elif [ -d "$prog" ]; then
        # Copy directories recursively
        cp -r "$prog" $out/bin/
      else
        # Copy non-executable files as-is
        cp "$prog" $out/bin/
      fi
    done
  '';

  meta = {
    mainProgram = "swift";
  };
})
