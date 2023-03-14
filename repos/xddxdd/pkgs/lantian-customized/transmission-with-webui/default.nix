{
  lib,
  sources,
  transmission,
  ...
}:
transmission.overrideAttrs (old: {
  postInstall =
    (old.postInstall or "")
    + ''
      mv $out/share/transmission/web/index.html $out/share/transmission/web/index.original.html
      cp -r ${sources.transmission-web-control.src}/src/* $out/share/transmission/web/
    '';
})
