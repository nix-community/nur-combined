/*
TODO binary patching
maybe with advanced-microcode-patching-shiva

building wine from source takes 4 hours on my 2x 2x 2.4 GHz cpu
but applying this trivial patch should take 1 minute
*/

{ lib
, wine
, lndir
, stdenvNoCC
}:

wine.overrideAttrs (oldAttrs: rec {

  pname = oldAttrs.pname + "-nocheckowner";
  version = oldAttrs.version;
  name = "${pname}-${version}";

  patchPhase = (oldAttrs.patchPhase or "") + ''
    runHook prePatch

    substituteInPlace server/request.c dlls/ntdll/unix/server.c \
      --replace-warn \
        'st->st_uid != getuid()' \
        '0' \
      --replace-warn \
        'st.st_uid != getuid()' \
        '0' \

    runHook postPatch
  '';

  meta = oldAttrs.meta // {
    description = (
      oldAttrs.meta.description +
      " [dont check ownership of wineprefix]"
    );
  };

})
