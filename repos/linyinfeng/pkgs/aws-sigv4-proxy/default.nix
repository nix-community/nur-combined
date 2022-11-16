{ sources, buildGoModule, lib }:

buildGoModule rec {
  inherit (sources.aws-sigv4-proxy) pname version src;

  # use vendor directory in src
  vendorSha256 = null;

  meta = with lib; {
    description = "Signs and proxies HTTP requests with Sigv4";
    homepage = "https://github.com/awslabs/aws-sigv4-proxy";
    license = licenses.asl20;
  };
}

