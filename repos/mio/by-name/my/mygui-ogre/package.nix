{
  lib,
  stdenv,
  mygui,
  ogre-1_11,
}:

# MyGUI built against our OGRE 1.11 pin (RoR's required major).
# On Darwin, clear nixpkgs' badPlatforms and fix libc++ char_traits removal
# (uint32/uint16 are no longer valid std::basic_string element types).
(mygui.override {
  withOgre = true;
  ogre = ogre-1_11;
}).overrideAttrs
  (
    old:
    {
      patches =
        (old.patches or [ ])
        ++ lib.optionals stdenv.hostPlatform.isDarwin [
          ./char-traits.patch
        ];
    }
    // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      meta = (old.meta or { }) // {
        badPlatforms = [ ];
      };
    }
  )
