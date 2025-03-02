{
  sources,
  buildGoModule,
  go,
  lib,
}:

buildGoModule rec {
  inherit (sources.aws-sigv4-proxy) pname version src;

  # use vendor directory in src
  vendorHash = null;

  meta = with lib; {
    description = "Signs and proxies HTTP requests with Sigv4";
    homepage = "https://github.com/awslabs/aws-sigv4-proxy";
    license = licenses.asl20;
    broken = !(lib.versionAtLeast go.version "1.23.6");
    maintainers = with maintainers; [ yinfeng ];
  };
}
