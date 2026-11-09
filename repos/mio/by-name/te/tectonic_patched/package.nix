{
  tectonic,
  tectonic-unwrapped,
}:

let
  tectonic-unwrapped_patched = tectonic-unwrapped.overrideAttrs (_oldAttrs: {
    dontCargoUseSystemLibs = true;
  });
in
(tectonic.override {
  tectonic-unwrapped = tectonic-unwrapped_patched;
}).overrideAttrs (_oldAttrs: {
  passthru = (tectonic.passthru or { }) // {
    unwrapped = tectonic-unwrapped_patched;
  };
})
