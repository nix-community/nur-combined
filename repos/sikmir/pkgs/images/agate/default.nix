{ dockerTools, agate, domain ? "localhost" }:
let
  key = "/certs/${domain}.key";
  cert = "/certs/${domain}.crt";
in
dockerTools.buildImage {
  name = "agate";
  tag = agate.version;

  contents = [ agate ];
  runAsRoot = "mkdir -p /certs /gemini";

  config = {
    Cmd = [ "agate" "--content" "/gemini" "--key" key "--cert" cert "--hostname" domain ];
    Volumes = {
      "/certs" = { };
      "/gemini" = { };
    };
    ExposedPorts = {
      "1965/tcp" = { };
    };
  };
}
