{ pkgs }:

{
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};

  applyFtdiFeature = attr: attr.overrideAttrs (finalAttrs: prevAttrs: {
    buildInputs = prevAttrs.buildInputs ++ [ pkgs.libftdi1 ];
    cargoBuildFeatures = prevAttrs.cargoBuildFeatures ++ [ "ftdi" ];
  });
}
