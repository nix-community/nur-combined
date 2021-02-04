{ dockerTools, writeText, gmnisrv, domain ? "localhost" }:

let
  cfg = writeText "gmnisrv.ini" ''
  listen=0.0.0.0:1965 [::]:1965

  [:tls]
  store=/certs

  [${domain}]
  root=/gemini
  '';
in
dockerTools.buildImage {
  name = "gmnisrv";
  tag = gmnisrv.version;

  contents = [ gmnisrv ];
  runAsRoot = "mkdir -p /certs /gemini";

  config = {
    Cmd = [ "gmnisrv" "-C" cfg ];
    Volumes = {
      "/certs" = { };
      "/gemini" = { };
    };
    ExposedPorts = {
      "1965/tcp" = { };
    };
  };
}
