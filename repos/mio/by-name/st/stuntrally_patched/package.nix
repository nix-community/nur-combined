{
  lib,
  ogre-next,
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
      substituteInPlace src/OgreCommon/GraphicsSystem.cpp \
        --replace-fail \
          'String( macBundlePath() + "/" + archName ), typeName, secName );' \
          '(archName[0] == 47 ? archName : String( macBundlePath() + "/" + archName )), typeName, secName );'
      substituteInPlace src/common/AppGui_Compositor.cpp \
        --replace-fail 'lens = edView ? 1 : pSet->g.lens_flare,' 'lens = false,' \
        --replace-fail 'sunbeams = edView ? 1 : pSet->g.sunbeams,' 'sunbeams = false,'
      substituteInPlace src/common/CScene_Sky.cpp \
        --replace-fail 'setForwardClustered(true' 'setForwardClustered(false'
      substituteInPlace data/Hlms/Pbs/Any/Main/200.Atmo_piece_all.any \
        --replace-fail 'constant AtmoSettings &atmo' 'constant SR3_AtmoSettings &atmo'
      substituteInPlace data/Hlms/Pbs/Any/Main/500.Structs_piece_vs_piece_ps.any \
        --replace-fail \
          '@property( envprobe_map && envprobe_map != target_envprobe_map && use_parallax_correct_cubemaps && !hlms_enable_cubemaps_auto )' \
          '@property( envprobe_map && envprobe_map != target_envprobe_map && use_parallax_correct_cubemaps && !hlms_enable_cubemaps_auto && syntax != metal )'
      substituteInPlace src/common/Atmosphere.cpp \
        --replace-fail 'int32( constBufferSlot )' 'int32( constBufferSlot + 6u )' \
        --replace-fail 'VertexShader, uint16( slotIdx )' 'VertexShader, uint16( slotIdx + 6u )' \
        --replace-fail 'PixelShader, uint16( slotIdx )' 'PixelShader, uint16( slotIdx + 6u )'
      substituteInPlace data/materials/Common/Metal/MipmapsGaussianBlur_cs.metal \
        --replace-fail 'i2Inc ),' 'i2Inc )' \
        --replace-fail 'p.dstLodIdx );' ');'
      substituteInPlace data/Hlms/Pbs/Any/Main/800.PixelShader_piece_ps.any \
        --replace-fail \
          '@property( !hlms_shadowcaster && !paint && !grass && !sky && refract )' \
          '@property( !hlms_shadowcaster && !paint && !grass && !sky && refract && syntax != metal )'
      substituteInPlace src/game/BaseApp.cpp \
        --replace-fail 'using namespace Ogre;' 'using namespace Ogre;

      namespace {
      void scaleMousePositionToGui(GraphicsSystem* graphics, int x, int y, int& guiX, int& guiY)
      {
          int windowWidth = 0, windowHeight = 0;
          SDL_GetWindowSize(graphics->mSdlWindow, &windowWidth, &windowHeight);
          const MyGUI::IntSize& viewSize = MyGUI::RenderManager::getInstance().getViewSize();

          guiX = windowWidth > 0 ? x * viewSize.width / windowWidth : x;
          guiY = windowHeight > 0 ? y * viewSize.height / windowHeight : y;
      }
      }' \
        --replace-fail 'MyGUI::InputManager::getInstance().injectMouseMove( xAbs, yAbs, whAbs );' 'int guiX = 0, guiY = 0;
      scaleMousePositionToGui(mGraphicsSystem, xAbs, yAbs, guiX, guiY);
      MyGUI::InputManager::getInstance().injectMouseMove( guiX, guiY, whAbs );' \
        --replace-fail 'arg.x, arg.y, sdlButtonToMyGUI(id));' 'guiX, guiY, sdlButtonToMyGUI(id));'
      substituteInPlace src/game/BaseApp.cpp \
        --replace-fail 'MyGUI::InputManager::getInstance().injectMousePress(' 'int guiX = 0, guiY = 0;
      scaleMousePositionToGui(mGraphicsSystem, arg.x, arg.y, guiX, guiY);
      MyGUI::InputManager::getInstance().injectMousePress(' \
        --replace-fail 'MyGUI::InputManager::getInstance().injectMouseRelease(' 'int guiX = 0, guiY = 0;
      scaleMousePositionToGui(mGraphicsSystem, arg.x, arg.y, guiX, guiY);
      MyGUI::InputManager::getInstance().injectMouseRelease('
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

      substituteInPlace "$out/share/stuntrally3/config/plugins.cfg" \
        --replace-fail 'PluginFolder=${ogre-next}/lib/OGRE/' 'PluginFolder=${ogre-next}/lib/' \
        --replace-fail 'PluginOptional=RenderSystem_GL3Plus' 'PluginOptional=RenderSystem_Metal' \
        --replace-fail 'PluginOptional=RenderSystem_Vulkan' '# PluginOptional=RenderSystem_Vulkan'
      substituteInPlace "$out/share/stuntrally3/config/resources3.cfg" \
        --replace-fail 'FileSystem=materials/Common/HLSL' 'FileSystem=materials/Common/HLSL
      FileSystem=materials/Common/Metal' \
        --replace-fail 'FileSystem=Hlms/Common/HLSL' 'FileSystem=Hlms/Common/HLSL
      FileSystem=Hlms/Common/Metal' \
        --replace-fail 'FileSystem=Hlms/Pbs/Any' 'FileSystem=Hlms/Pbs/Any
      FileSystem=Hlms/Pbs/Metal' \
        --replace-fail 'FileSystem=Hlms/Compute/Tools/Metal' 'FileSystem=Hlms/Compute/Tools/Metal
      FileSystem=Hlms/Unlit/Metal
      FileSystem=Hlms/Terra/Metal'
      mkdir -p "$out/bin/Contents/Resources"
      cp "$out/share/stuntrally3/config/plugins.cfg" "$out/bin/Contents/Resources/plugins.cfg"
      cp "$out/share/stuntrally3/config/resources3.cfg" "$out/bin/Contents/Resources/resources3.cfg"
    '';
})
