{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  swift-corelibs-icu,
  swift_release,
}:

stdenvNoCC.mkDerivation {
  pname = "swift-foundation-icu";
  version = lib.getVersion swift-corelibs-icu;

  src = fetchFromGitHub {
    owner = "swiftlang";
    repo = "swift-foundation-icu";
    tag = "swift-${swift_release}-RELEASE";
    hash = "sha256-C2rq5Q0F1id89mTN4+B/fKSvX1SEAf3/Zgvb/3IdsJ8=";
  };

  propagatedBuildInputs = [ (lib.getLib swift-corelibs-icu) ];

  buildCommand = ''
    runPhase unpackPhase

    # Provide a CMake module. This is primarily used to glue together parts of the Swift toolchain.
    # Upstream provides a build that does this for us, but we want to reuse our existing ICU build.
    mkdir -p "''${!outputDev}/lib/cmake/SwiftFoundationICU"
    export dylibExt="${stdenvNoCC.hostPlatform.extensions.sharedLibrary}"

    substitute ${./files/SwiftFoundationICUConfig.cmake} "''${!outputDev}/lib/cmake/SwiftFoundationICU/SwiftFoundationICUConfig.cmake" \
      --replace-fail '@buildType@' ${if stdenvNoCC.hostPlatform.isStatic then "STATIC" else "SHARED"} \
      --replace-fail '@lib@' ${lib.escapeShellArg (lib.getLib swift-corelibs-icu)} \
      --replace-fail '@dev@' "''${!outputDev}"

    # Copy headers to `_foundation_unicode`. The translation is needed to make sure they’re found in the tooclhain.
    mkdir -p "$out/lib/swift/_foundation_unicode"
    for header in ${lib.escapeShellArg (lib.getInclude swift-corelibs-icu)}/include/unicode/*; do
      # Not all files include other files, so these can’t be `--replace-fail`. Use both `"` and `<` to be thorough.
      substitute "$header" "$out/lib/swift/_foundation_unicode/$(basename "$header")" \
        --replace-quiet 'include "unicode/' 'include "_foundation_unicode/' \
        --replace-quiet 'include <unicode/' 'include <_foundation_unicode/'
    done
    cp icuSources/include/_foundation_unicode/module.modulemap "$out/lib/swift/_foundation_unicode/module.modulemap"

    recordPropagatedDependencies
  '';

  meta = {
    description = "Shim package allowing the Darwin ICU packaging to be used with Swift Foundation.";
    license = swift-corelibs-icu.meta.license or lib.licenses.icu;
    platforms = swift-corelibs-icu.meta.platforms or lib.platforms.unix;
    teams = [ lib.teams.swift ];
  };
}
