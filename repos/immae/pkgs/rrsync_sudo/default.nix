{ rrsync }:

rrsync.overrideAttrs(old: {
  patches = old.patches or [] ++ [ ./sudo.patch ];
  postPatch = old.postPatch + ''
    substituteInPlace support/rrsync --replace /usr/bin/sudo /run/wrappers/bin/sudo
  '';
})
