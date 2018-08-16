{ gdbgui }:
# patched to unlock "full" version
gdbgui.overrideAttrs (old: {
  patches = [ ./gdbgui.patch ];
})
