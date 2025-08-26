{
  openscad-unstable,
  symlinkJoin,
  makeWrapper,
}: plist: let
  libs = symlinkJoin {
    name = "openscad-libs";
    paths = plist;
  };
in
  symlinkJoin {
    name = "openscad-with-packages";
    paths = [openscad-unstable];
    buildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/openscad \
        --set OPENSCADPATH ${libs}
    '';
  }
