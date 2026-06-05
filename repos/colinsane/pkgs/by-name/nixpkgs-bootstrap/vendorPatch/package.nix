{
  stdenv,
  vendor-patch-updater,
}:
{ name }@args: stdenv.mkDerivation {
  inherit name;
  src = ../patches/${name}.patch;
  dontUnpack = true;
  installPhase = ''
    ln -s "$src" "$out"
  '';
  dontFixup = true;

  passthru.updateScript = vendor-patch-updater.makeUpdateScript {
    ident = name;
  };

  meta.position = builtins.unsafeGetAttrPos "name" args;
}
