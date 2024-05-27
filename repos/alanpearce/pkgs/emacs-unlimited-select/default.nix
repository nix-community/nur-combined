{ stdenv
, lib
, emacs
}:

emacs.overrideAttrs (old: {
  NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") +
    " -DFD_SETSIZE=10000 -DDARWIN_UNLIMITED_SELECT";

  meta = with lib; old.meta // {
    broken = !stdenv.isDarwin;
    platforms = platforms.darwin;
  };
})
