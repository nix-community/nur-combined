{
  lib,
  sources,
  googleearth-pro,
}:
googleearth-pro.overrideAttrs (old: {
  inherit (sources.google-earth-pro) pname version src;
  unpackPhase = ''
    # deb file contains a setuid binary, so 'dpkg -x' doesn't work here
    mkdir deb
    dpkg --fsys-tarfile $src | tar --extract -C deb
  '';
  meta = (builtins.removeAttrs old.meta [ "knownVulnerabilities" ]) // {
    platforms = [ "x86_64-linux" ];
  };
})
