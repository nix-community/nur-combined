{ lib
, coredns
, buildGoModule
, ...
} @ args:

buildGoModule rec {
  inherit (coredns) pname version src vendorSha256 meta;

  doCheck = false;
  patches = [ ./patches/large-axfr.patch ];

  preBuild = ''
  '';
}
