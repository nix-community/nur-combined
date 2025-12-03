final: prev:
let
  mk =
    oldAttr: newAttr:
    let
      oldPy = final.${oldAttr};
      withAttrs = oldPy.overrideAttrs (
        finalAttrs: prevAttrs: {
          postInstall = (prevAttrs.postInstall or "") + ''
            ln -s $out/bin/python3.14 $out/bin/πthon
            ln -s $out/bin/python3.14-config $out/bin/πthon-config
            ln -s $out/bin/pydoc3.14 $out/bin/πdoc
          '';
        }
      );
      newPy = withAttrs.override {
        self = newPy;
        pythonAttr = newAttr;
      };
    in
    newPy;
in
if (prev ? python314) then
  {
    "πthon" = mk "python314" "πthon";
    "πthonFreeThreading" = mk "python314FreeThreading" "πthonFreeThreading";
    "πthonFull" = mk "python314Full" "πthonFull";
    "πthonPackages" = final.lib.recurseIntoAttrs final."πthon".pkgs;
  }
else
  { }
