{ pkgsStatic }:

pkgsStatic.dash.overrideAttrs {
  buildInputs = [ ];
  configureFlags = [ ];
  outputs = [
    "out"
    "dev"
  ];
}
