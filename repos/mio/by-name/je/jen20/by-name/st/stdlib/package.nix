# Sources: reckenrode/nixpkgs swift-update-mk2 @ 9bd6cfed…;
# LTO + llc bitcode conversion from Randy Eckenrode (Matrix / mk2); jen20 gist used clang -x ir equivalently.
{
  lib,
  llvmPackages,
  stdenv,
  swiftc,
}:

let
  swiftPlatform = stdenv.hostPlatform.swift.platform;
  libraryExtension = stdenv.hostPlatform.extensions.library;

  toolLTO = lib.cmakeFeature "SWIFT_TOOLS_ENABLE_LTO" "thin";
in
(swiftc.override {
  stdlib = null;
  swiftComponents = [
    "back-deployment"
    "sdk-overlay"
    "static-mirror-lib"
    "swift-remote-mirror"
    "swift-remote-mirror-headers"
    "stdlib"
  ];
}).overrideAttrs
  (old: {
    pname = "stdlib";

    outputs = [
      "out"
      "dev"
    ];

    cmakeFlags =
      # Only enable LTO for the stdlib. Remove it if it’s enabled for the tools.
      (lib.filter (flag: flag != toolLTO) (old.cmakeFlags or [ ]))
      # LTO is slow (and pointless due to using system libraries) on Darwin, so only enable it for other platforms.
      # Enabled per Nixpkgs Swift Matrix discussion; bitcode members are converted with llc below
      # (Randy Eckenrode’s approach on swift-update-mk2; jen20 verified aarch64-linux with an equivalent postInstall).
      ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
        (lib.cmakeFeature "SWIFT_STDLIB_ENABLE_LTO" "thin")
      ];

    postInstall = ''
      moveToOutput "lib/swift/${swiftPlatform}" "''${!outputLib}"

      # Static libraries, Swift modules, and shims are only needed for development.
      moveToOutput "lib/swift/${swiftPlatform}/*.swiftmodule" "''${!outputDev}"
      moveToOutput "lib/swift/_InternalSwiftStaticMirror" "''${!outputDev}"
      moveToOutput "lib/swift/embedded" "''${!outputDev}"
      moveToOutput "lib/swift/module.modulemap" "''${!outputDev}"
      moveToOutput "lib/swift/shims" "''${!outputDev}"
      moveToOutput "lib/swift_static" "''${!outputDev}"

      # Move libraries out of `lib/swift/`, so ld-wrapper will find them automatically.
      mv -v "''${!outputLib}/lib/swift/${swiftPlatform}"/*${libraryExtension} "''${!outputLib}/lib"

      # Install C++ interop libraries and headers
      cp -v lib/swift/${swiftPlatform}/libswiftCxx*${stdenv.hostPlatform.extensions.staticLibrary} "''${!outputDev}/lib"
      cp -rv lib/swift/${swiftPlatform}/Cxx*.swiftmodule "''${!outputDev}/lib/swift/${swiftPlatform}"

      mkdir -p "''${!outputDev}/include/swiftToCxx"
      cp -v ../lib/PrintAsClang/{_SwiftCxxInteroperability.h,_SwiftStdlibCxxOverlay.h,experimental-interoperability-version.json} \
        "''${!outputDev}/include/swiftToCxx"
      cp -v lib/swift/${swiftPlatform}/libcxx* "''${!outputDev}/lib/swift/${swiftPlatform}"
    ''
    # libstdc++ does not come with a modulemap. It needs one provided by Swift.
    + lib.optionalString (stdenv.cc.libcxx == null) ''
      moveToOutput "lib/swift/${swiftPlatform}/libstdcxx.*" "''${!outputDev}"
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      # Linux has some extra development files that need moved to $dev
      moveToOutput lib/swift/${swiftPlatform}/${stdenv.hostPlatform.swift.arch} "''${!outputDev}"
    ''
    + lib.optionalString stdenv.hostPlatform.isElf ''
      # Convert LLVM bitcode files into native code to avoid requiring LTO for C++ interop /
      # ordinary links. Swift does not support FatLTO (`-ffat-lto-objects` is ignored by
      # swift-frontend); thin LTO leaves pure bitcode in .o/.a that system linkers reject
      # (`file format not recognized` for swiftrt.o, `archive has no index` for Cxx).
      # Approach from reckenrode on swift-update-mk2 (Matrix); jen20 gist used clang -x ir.
      llc=${lib.escapeShellArg (lib.getExe' llvmPackages.llvm "llc")}
      # PIC: default llc reloc model emits R_X86_64_32S against __start_swift5_*,
      # which ld.bfd rejects when linking PIE (cmake Swift compiler checks, etc.).
      llcFlags=(-filetype=obj -relocation-model=pic)
      $llc "''${llcFlags[@]}" stdlib/public/Cxx/${lib.toUpper stdenv.hostPlatform.swift.platform}/${stdenv.hostPlatform.swift.arch}/Cxx.o -o Cxx.o
      "$AR" Drs "''${!outputDev}/lib/libswiftCxx.a" Cxx.o
      $llc "''${llcFlags[@]}" stdlib/public/Cxx/std/${lib.toUpper stdenv.hostPlatform.swift.platform}/${stdenv.hostPlatform.swift.arch}/CxxStdlib.o -o CxxStdlib.o
      "$AR" Drs "''${!outputDev}/lib/libswiftCxxStdlib.a" CxxStdlib.o
      # Runtime startup object is also bitcode under thin LTO; convert in place under $dev.
      while IFS= read -r -d "" swiftrt; do
        $llc "''${llcFlags[@]}" "$swiftrt" -o swiftrt.native.o
        mv -f swiftrt.native.o "$swiftrt"
      done < <(find "''${!outputDev}" -name swiftrt.o -print0)
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # Back-deployment libraries are installed as part of the compiler component, so install them manually.
      cp -rv lib/swift/macosx/libswiftCompatibility*.a "''${!outputDev}/lib"
      # Install `Span`-compatibility back-deployment library.
      mkdir -p "''${!outputLib}/lib/swift-6.2/macosx"
      cp -v lib/swift-6.2/macosx/libswiftCompatibilitySpan.dylib "''${!outputLib}/lib/swift-6.2/macosx/libswiftCompatibilitySpan.dylib"
      # macOS 26.4 dropped the Swift Differentiation dylibs. Use the one in the store instead of `/usr/lib/swift`.
      install_name_tool "''${!outputLib}/lib/libswift_Differentiation.dylib" -id "''${!outputLib}/lib/libswift_Differentiation.dylib"

      # Clean up empty folders.
      rmdir "''${!outputLib}/lib/swift/${swiftPlatform}" "''${!outputLib}/lib/swift"
    '';
  })
