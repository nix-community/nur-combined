{
  lib,
  stdenv,
  angelscript,
  fetchzip,
}:

# RoR still targets the 2.35.x AngelScript API; nixpkgs ships a newer release.
# On aarch64-darwin the 2.35.1 tree only ships the GNU `as_callfunc_arm64_gcc.S`
# (`.type` directives), so we vendor the Apple `as_callfunc_arm64_xcode.S` from
# later AngelScript and select it the same way upstream CMake does since 2.38.
angelscript.overrideAttrs (
  old:
  let
    version = "2.35.1";
  in
  {
    inherit version;
    src = fetchzip {
      url = "https://www.angelcode.com/angelscript/sdk/files/angelscript_${version}.zip";
      hash = "sha256-ncs3pPsJErx3el8/Lsj+NSu7LQ1hPRlBmcTSvLGWL1s=";
    };

    postPatch =
      (old.postPatch or "")
      + lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) ''
        cp ${./as_callfunc_arm64_xcode.S} angelscript/source/as_callfunc_arm64_xcode.S
        substituteInPlace angelscript/projects/cmake/CMakeLists.txt \
          --replace-fail \
            'set(ANGELSCRIPT_SOURCE ''${ANGELSCRIPT_SOURCE} ../../source/as_callfunc_arm64.cpp ../../source/as_callfunc_arm64_gcc.S)' \
            'if(NOT APPLE)
                    set(ANGELSCRIPT_SOURCE ''${ANGELSCRIPT_SOURCE} ../../source/as_callfunc_arm64.cpp ../../source/as_callfunc_arm64_gcc.S)
                else()
                    set(ANGELSCRIPT_SOURCE ''${ANGELSCRIPT_SOURCE} ../../source/as_callfunc_arm64.cpp ../../source/as_callfunc_arm64_xcode.S)
                endif()'
      '';
  }
)
