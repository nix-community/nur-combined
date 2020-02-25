{ lib, libSuper }:

let
  # lib imports {{{1
  inherit (lib.meta) #{{{1
    addMetaAttrs' # (mod)
    setDrvBroken breakDrv unbreakDrv # (mod)
  ; #}}}1
in {

  # addMetaAttrs' {{{2
  /* Add to or override the meta attributes of the given derivation.

     Uses the `overrideAttrs` attribute instead of directly updating the
     derivation set.

     Type: addMetaAttrs' :: attrs -> derivation -> derivation

     Example:
       addMetaAttrs { description = "Bla blah"; } somePkg
  */
  addMetaAttrs' = newAttrs: drv:
    drv.overrideAttrs (origAttrs: {
      meta = origAttrs.meta or { } // newAttrs;
    });

  # setDrvBroken [breakDrv unbreakDrv] {{{2
  /* Change the broken mark of a package.

     Type: setDrvBroken :: bool -> derivation -> derivation

     Example:
       setDrvBroken true somePkg
  */
  setDrvBroken = broken: addMetaAttrs' { inherit broken; };

  # breakDrv {{{3
  /* Mark a package as broken.

     Type: breakDrv :: derivation -> derivation

     Example:
       breakDrv somePkg
  */
  breakDrv = setDrvBroken true;

  # unbreakDrv {{{3
  /* Mark a package as not broken.

     Type: unbreakDrv :: derivation -> derivation

     Example:
       unbreakDrv somePkg
  */
  unbreakDrv = setDrvBroken false;

  #}}}1

}
# vim:fdm=marker:fdl=1
