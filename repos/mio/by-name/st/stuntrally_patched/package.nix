{
  lib,
  stdenv,
  stuntrally,
}:

let
  darwin = stdenv.hostPlatform.isDarwin;
  mygui_patched = stuntrally.passthru.mygui.overrideAttrs (oldAttrs: {
    meta = (oldAttrs.meta or { }) // {
      platforms = (oldAttrs.meta.platforms or [ ]) ++ [ "aarch64-darwin" ];
    };
    buildInputs = builtins.filter (x: (x.pname or "") != "libx11" || !darwin) oldAttrs.buildInputs;
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
      (lib.cmakeBool "CMAKE_CXX_STANDARD_REQUIRED" true)
    ];
  });
in
stuntrally.overrideAttrs (oldAttrs: {
  meta = (oldAttrs.meta or { }) // {
    platforms = (oldAttrs.meta.platforms or [ ]) ++ [ "aarch64-darwin" ];
  };
  cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
    (lib.cmakeBool "CMAKE_CXX_STANDARD_REQUIRED" true)
  ];
  buildInputs =
    builtins.filter (
      x: (x.pname or "") != "mygui" && ((x.pname or "") != "libx11" || !darwin)
    ) oldAttrs.buildInputs
    ++ [ mygui_patched ];
  patches =
    (oldAttrs.patches or [ ]) ++ lib.optionals darwin [ ./stuntrally-darwin-window-handle.patch ];
  postPatch =
    (oldAttrs.postPatch or "")
    + lib.optionalString darwin ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'project( StuntRally3 )' 'project( StuntRally3 )

      if (APPLE)
          enable_language(OBJCXX)
      endif ()' \
        --replace-fail 'add_executable(''${EXE} WIN32 ''${EXE_SOURCES})' 'if (APPLE)
          list(APPEND EXE_SOURCES ./src/OgreCommon/System/OSX/OSXUtils.mm)
      endif ()
      add_executable(''${EXE} WIN32 ''${EXE_SOURCES})' \
        --replace-fail '            Vorbis::vorbisfile' '            Vorbis::vorbisfile
            "-framework AppKit"'
      substituteInPlace src/vdrift/numprocessors.h \
        --replace-fail '#pragma once' '#pragma once

      #include <sys/time.h>'
      substituteInPlace src/editor/App_TerrainEdit.cpp \
        --replace-fail 'Rect& rcBrush, Rect& rcMap' 'Ogre::Rect& rcBrush, Ogre::Rect& rcMap' \
        --replace-fail '= Rect(mapX-hBr, mapY-hBr, mapX+hBr, mapY+hBr)' '= Ogre::Rect(mapX-hBr, mapY-hBr, mapX+hBr, mapY+hBr)' \
        --replace-fail '= Rect(0,0, brS,brS)' '= Ogre::Rect(0,0, brS,brS)' \
        --replace-fail 'Rect rcBrush, rcMap;' 'Ogre::Rect rcBrush, rcMap;'
      substituteInPlace src/editor/AlignTerToRoad.cpp \
        --replace-fail 'dirtyRect(Rect(0,0,1,1))' 'dirtyRect(Ogre::Rect(0,0,1,1))'
    '';
  passthru = (oldAttrs.passthru or { }) // {
    mygui = mygui_patched;
  };
  installPhase =
    if darwin then
      lib.replaceStrings
        [
          "# Force X11, otherwise fails with `OGRE EXCEPTION(9:UnimplementedException)`"
          "--set SDL_VIDEODRIVER x11"
        ]
        [ "# Let SDL select the native Darwin video driver." "--unset SDL_VIDEODRIVER" ]
        oldAttrs.installPhase
    else
      oldAttrs.installPhase;
  postInstall =
    (oldAttrs.postInstall or "")
    + lib.optionalString darwin ''
      mkdir -p "$out/Frameworks"
      cp -R ${mygui_patched}/lib/Release/MyGUIEngine.framework "$out/Frameworks/"
    '';
})
