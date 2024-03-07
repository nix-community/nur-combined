{
  lib,
  stdenv,
  colima,
}:
colima.overrideAttrs (finalAttrs: prevAttrs: {
  version = prevAttrs.version + "-1";
  name = "${prevAttrs.pname}-${finalAttrs.version}";
  postPatch =
    lib.optionalString stdenv.isDarwin (prevAttrs.postPatch or "")
    + ''
      substituteInPlace config/dirs.go \
        --replace '"github.com/abiosoft/colima/util"' "" \
        --replace " || util.MacOS()" ""
    '';

  meta = prevAttrs.meta // {
    description = "Patched colima which supports xdg base directory on darwin";
  };
})
