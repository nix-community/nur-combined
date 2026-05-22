{
  cxadc-vhs-server,
  fetchFromGitHub,
  flac,
  sox,
  ...
}:
let
  pname = "cxadc-vhs-server-jitterbug";
  version = "1.4.0-unstable-024-05-24";

  rev = "c7969eb48376d9f3a0cd88bf87d2f1c9b030579f";
  hash = "sha256-3DrCcxvCt0ZszC1mqWagqgtjXmHsTqlEsTrTMYjQqUc=";
in
(cxadc-vhs-server.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      inherit hash rev;
      owner = "JuniorIsAJitterbug";
      repo = "cxadc_vhs_server";
    };

    buildInputs = prevAttrs.buildInputs ++ [
      flac
      sox
    ];

    meta.homepage = "https://github.com/JuniorIsAJitterbug/cxadc_vhs_server";
  }
))
