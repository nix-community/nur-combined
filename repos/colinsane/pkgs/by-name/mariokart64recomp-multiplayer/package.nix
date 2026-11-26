{
  lib,
  mariokart64recomp,
}:
mariokart64recomp.overrideAttrs (prevAttrs: {
  # https://github.com/sonicdcer/MarioKart64Recomp/pull/38
  src = prevAttrs.src.override {
    rev = "8b808c53ae73cc53999e151388284c3a689048db";
    tag = null;
    hash = "sha256-bhl8d8U71jocoQik7avLNaYh2E1EgxuOc1TXHGuyQg0=";
  };

  # The PR updates ImGui, which already initializes empty_string.
  preConfigure =
    lib.replaceStrings
      [
        ''
          # Fix llvm 21 rt64 error:
          # error: variable 'empty_string' is uninitialized when passed as a const pointer argument here
          substituteInPlace lib/rt64/src/contrib/imgui/imgui_widgets.cpp \
            --replace-fail "IMSTB_TEXTEDIT_CHARTYPE empty_string;" "IMSTB_TEXTEDIT_CHARTYPE empty_string = 0;"
        ''
      ]
      [ "" ]
      prevAttrs.preConfigure;

  postPatch = (prevAttrs.postPatch or "") + ''
    # RecompFrontend now builds its own copy of RmlUi.
    substituteInPlace lib/RecompFrontend/recompui/lib/RmlUi/Include/RmlUi/Core/Containers/robin_hood.h \
      --replace-fail '#include <cstdlib>' $'#include <cstdint>\n#include <cstdlib>'
  '';

  installPhase =
    lib.replaceStrings
      [ "../lib/RmlUi/" "../lib/lunasvg/" ]
      [ "../lib/RecompFrontend/recompui/lib/RmlUi/" "../lib/RecompFrontend/recompui/lib/lunasvg/" ]
      prevAttrs.installPhase;
})
