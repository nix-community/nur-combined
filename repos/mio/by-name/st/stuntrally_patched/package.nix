{
  stuntrally,
}:

let
  mygui_patched = stuntrally.passthru.mygui.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace MyGUIEngine/include/MyGUI_Allocator.h \
        --replace-fail "typename std::allocator<void>::const_pointer = 0" "const void* = 0"
    '';
  });
in
stuntrally.overrideAttrs (oldAttrs: {
  buildInputs = (builtins.filter (x: (x.pname or "") != "mygui") oldAttrs.buildInputs) ++ [
    mygui_patched
  ];
  passthru = (oldAttrs.passthru or { }) // {
    mygui = mygui_patched;
  };
})
