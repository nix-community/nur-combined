{ bluez }:
bluez.overrideAttrs( old: {
  configureFlags = (old.configureFlags or []) ++ [ "--enable-deprecated" ];
  makeFlags = [ "attrib/gatttool" ];
  doCheck = false;
  outputs = [ "out" ];
  installPhase = ''
    install -D attrib/gatttool $out/bin/gatttool
  '';
})
