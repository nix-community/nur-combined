{
  lib,
  stuntrally,
}:

let
  mygui_patched = stuntrally.passthru.mygui.overrideAttrs (oldAttrs: {
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
      (lib.cmakeBool "CMAKE_CXX_STANDARD_REQUIRED" true)
    ];
  });
in
stuntrally.overrideAttrs (oldAttrs: {
  cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
    (lib.cmakeBool "CMAKE_CXX_STANDARD_REQUIRED" true)
  ];
  buildInputs = (builtins.filter (x: (x.pname or "") != "mygui") oldAttrs.buildInputs) ++ [
    mygui_patched
  ];
  passthru = (oldAttrs.passthru or { }) // {
    mygui = mygui_patched;
  };
})
