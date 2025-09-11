{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule (finalAttrs: {
  name = "h3get";

  src = fetchFromGitHub {
    owner = "nixigaj";
    repo = "h3get";
    rev = "2515e0e32c6c46dbc2d12d8fa1d8ae91bf33b751";
    hash = "sha256-cL5543QWoDAkAd8wmxUR9UF7n7paoVPL590syhvH3XU=";
  };

  vendorHash = "sha256-wnUXbvTGZOTTt617u5mmjQ67bIogVUv/8lGhP9hjc2Y=";

  meta = {
    description = "A dead simple curl-like HTTP/3 client";
    homepage = "https://github.com/nixigaj/h3get";
    license = lib.licenses.mit;
    mainProgram = "h3get";
  };
})
