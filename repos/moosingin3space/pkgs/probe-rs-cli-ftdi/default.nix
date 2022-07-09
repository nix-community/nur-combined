{ probe-rs-cli, libftdi1 }:

probe-rs-cli.overrideAttrs (finalAtrrs: prevAttrs: {
  buildInputs = prevAttrs.buildInputs ++ [ libftdi1 ];
  cargoBuildFeatures = ["ftdi"];
})
